import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  static const _profileKey = 'purse_profile_v1';
  static const _passwordKey = 'purse_password_v1';
  static const _signedOutKey = 'purse_signed_out_v1';

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final signedOut = prefs.getBool(_signedOutKey) ?? false;
    if (signedOut) return null;
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr == null) return null;
    final Map<String, dynamic> data = json.decode(jsonStr);
    return UserProfile.fromJson(data);
  }

  Future<UserProfile?> loadProfileIgnoringSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_profileKey);
    if (jsonStr == null) return null;
    final Map<String, dynamic> data = json.decode(jsonStr);
    return UserProfile.fromJson(data);
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(profile.toJson()));
  }

  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, _hash(password));
  }

  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_passwordKey);
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final isValid = await verifyPassword(currentPassword);
    if (!isValid) return false;
    await savePassword(newPassword);
    return true;
  }

  Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_passwordKey);
    if (stored == null) return false;
    return stored == _hash(password);
  }

  Future<void> markSignedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedOutKey, true);
  }

  Future<void> clearSignedOutFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_signedOutKey);
  }

  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
