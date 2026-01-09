import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _restore();
  }

  final AuthService _authService;
  UserProfile? _user;
  bool _loading = true;
  String? _error;

  UserProfile? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  Future<void> _restore() async {
    _loading = true;
    notifyListeners();
    _user = await _authService.loadProfile();
    _loading = false;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _error = null;
    _loading = true;
    notifyListeners();
    final normalizedInputEmail = email.trim().toLowerCase();
    final storedProfile = await _authService.loadProfileIgnoringSignOut();
    final normalizedStoredEmail = storedProfile?.email.trim().toLowerCase();

    final hasPassword = await _authService.hasPassword();
    final passwordOk = await _authService.verifyPassword(password);

    // Migration/fallback: if password was wiped but profile matches, accept and re-save hash
    if (!passwordOk && !hasPassword && storedProfile != null && normalizedStoredEmail == normalizedInputEmail) {
      await _authService.savePassword(password);
      await _authService.clearSignedOutFlag();
      _user = storedProfile;
      _loading = false;
      notifyListeners();
      return true;
    }

    if (!passwordOk || storedProfile == null || normalizedStoredEmail != normalizedInputEmail) {
      _error = 'Invalid credentials';
      _loading = false;
      notifyListeners();
      return false;
    }

    await _authService.clearSignedOutFlag();
    _user = storedProfile;
    _loading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _error = null;
    _loading = true;
    notifyListeners();

    final newProfile = UserProfile(
      id: _generateId(),
      email: email.trim(),
      displayName: displayName.trim(),
      avatarImagePath: null,
      createdAt: DateTime.now(),
    );

    await _authService.saveProfile(newProfile);
    await _authService.savePassword(password);

    // ensure new sessions are considered signed-in
    await _authService.clearSignedOutFlag();

    _user = newProfile;
    _loading = false;
    notifyListeners();
    return true;
  }

  Future<void> updateProfile({String? displayName, String? avatarImagePath}) async {
    if (_user == null) return;
    final updated = _user!.copyWith(
      displayName: displayName,
      avatarImagePath: avatarImagePath,
    );
    _user = updated;
    await _authService.saveProfile(updated);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.markSignedOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
		// Clear any previous errors
		_error = null;
		_loading = true;
		notifyListeners();

		// Verify current password and update only if verification succeeds
		final ok = await _authService.updatePassword(
			currentPassword: currentPassword,
			newPassword: newPassword,
		);

		if (!ok) {
			// Current password verification failed
			_error = 'Current password is incorrect. Please try again.';
			_loading = false;
			notifyListeners();
			return false;
		}

		// Password updated successfully
		_loading = false;
		notifyListeners();
		return true;
	}

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
