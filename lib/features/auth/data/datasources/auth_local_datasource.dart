import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Handles local caching of auth tokens and user data.
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<String?> getRefreshToken();
  Future<void> saveRefreshToken(String token);
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    required this.prefs,
    required this.secureStorage,
  });

  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final json = prefs.getString(AppConstants.userKey);
      if (json == null) return null;
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearUser() async {
    await prefs.remove(AppConstants.userKey);
  }

  @override
  Future<String?> getToken() async {
    return secureStorage.read(key: AppConstants.tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      secureStorage.delete(key: AppConstants.tokenKey),
      secureStorage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }
}
