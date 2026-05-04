import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const tokenType = 'token_type';
  static const expiresIn = 'expires_in';
}

abstract class TokenStorageContract {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<String?> readTokenType();

  Future<String?> readExpiresIn();

  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  });

  Future<void> clear();
}

class TokenStorage implements TokenStorageContract {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> readAccessToken() => _read(AuthStorageKeys.accessToken);

  @override
  Future<String?> readRefreshToken() => _read(AuthStorageKeys.refreshToken);

  @override
  Future<String?> readTokenType() => _read(AuthStorageKeys.tokenType);

  @override
  Future<String?> readExpiresIn() => _read(AuthStorageKeys.expiresIn);

  @override
  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  }) async {
    if (accessToken != null) {
      await _write(AuthStorageKeys.accessToken, accessToken);
    }
    if (refreshToken != null) {
      await _write(AuthStorageKeys.refreshToken, refreshToken);
    }
    if (tokenType != null) {
      await _write(AuthStorageKeys.tokenType, tokenType);
    }
    if (expiresIn != null) {
      await _write(AuthStorageKeys.expiresIn, expiresIn.toString());
    }
  }

  @override
  Future<void> clear() async {
    await _delete(AuthStorageKeys.accessToken);
    await _delete(AuthStorageKeys.refreshToken);
    await _delete(AuthStorageKeys.tokenType);
    await _delete(AuthStorageKeys.expiresIn);
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _secureStorage.read(key: key);
  }

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }
    await _secureStorage.write(key: key, value: value);
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }
    await _secureStorage.delete(key: key);
  }
}
