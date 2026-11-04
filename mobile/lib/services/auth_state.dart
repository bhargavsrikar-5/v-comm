import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

/// Holds the signed-in user and stores the bearer token in platform secure storage.
class AuthState {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'vcomm_access_token';
  static const _userKey = 'vcomm_current_user';
  static const _expiresAtKey = 'vcomm_token_expires_at';

  UserModel? currentUser;
  String? accessToken;
  bool _initialized = false;

  bool get isLoggedIn => currentUser != null && accessToken != null && accessToken!.isNotEmpty;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      accessToken = await _storage.read(key: _tokenKey);
      final storedUser = await _storage.read(key: _userKey);
      final expiresAtValue = await _storage.read(key: _expiresAtKey);
      final expiresAt = expiresAtValue == null ? null : DateTime.tryParse(expiresAtValue);
      if (accessToken == null || accessToken!.isEmpty || storedUser == null ||
          expiresAt == null || !expiresAt.isAfter(DateTime.now().toUtc())) {
        await logout();
      } else {
        currentUser = UserModel.fromJson(jsonDecode(storedUser) as Map<String, dynamic>);
      }
    } catch (_) {
      await logout();
    } finally {
      _initialized = true;
    }
  }

  Future<void> setSession(UserModel user, String token, {required int expiresInSeconds}) async {
    currentUser = user;
    accessToken = token;
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    final expiresAt = DateTime.now().toUtc().add(Duration(seconds: expiresInSeconds));
    await _storage.write(key: _expiresAtKey, value: expiresAt.toIso8601String());
    _initialized = true;
  }

  /// Update profile information locally and persist the refreshed profile snapshot.
  void setUser(UserModel user) {
    currentUser = user;
    if (accessToken != null) {
      unawaited(_persistProfile(user));
    }
  }

  Future<void> _persistProfile(UserModel user) async {
    try {
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    } catch (_) {
      // A transient secure-storage error should not interrupt profile editing.
    }
  }

  Future<void> logout() async {
    currentUser = null;
    accessToken = null;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _expiresAtKey);
    } catch (_) {
      // The in-memory session is cleared even when the platform store is unavailable.
    }
    _initialized = true;
  }
}
