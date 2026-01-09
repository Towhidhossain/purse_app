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

  /// Saves a new password securely using SHA-256 hashing.
  /// Never stores plain text passwords.
  Future<void> savePassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passwordKey, _hash(password));
  }

  /// Checks if a password has been set for the user.
  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_passwordKey);
  }

  /// Updates the password only if the current password is verified.
  /// 
  /// Returns `true` if the current password was correct and the new password
  /// was saved successfully. Returns `false` if the current password is incorrect.
  /// 
  /// This ensures secure password changes by:
  /// 1. Verifying the current password against the stored hash
  /// 2. Only updating if verification succeeds
  /// 3. Using SHA-256 hashing for password storage
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Verify current password before allowing update
    final isValid = await verifyPassword(currentPassword);
    if (!isValid) return false;
    
    // Only update password if current password is correct
    await savePassword(newPassword);
    return true;
  }

  /// Verifies a password against the stored hash.
  /// Returns `true` if the password matches, `false` otherwise.
  /// Uses SHA-256 hashing for secure comparison.
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

  /// Hashes a password using SHA-256 algorithm.
  /// This ensures passwords are never stored in plain text.
  /// Returns the hex-encoded hash string.
  String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
