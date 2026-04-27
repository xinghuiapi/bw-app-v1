import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthHelper {
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // 对于原生平台使用加密存储
  static const _storage = FlutterSecureStorage();

  /// 获取 Token
  static Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_tokenKey);
      }
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('获取 Token 失败: $e');
      return null;
    }
  }

  /// 设置 Token
  static Future<void> setToken(String token) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        return;
      }
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('保存 Token 失败: $e');
    }
  }

  /// 清除 Token
  static Future<void> clearToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        await prefs.remove(_refreshTokenKey);
        return;
      }
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('清除 Token 失败: $e');
    }
  }

  /// 获取 Refresh Token
  static Future<String?> getRefreshToken() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_refreshTokenKey);
      }
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  /// 设置 Refresh Token
  static Future<void> setRefreshToken(String token) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_refreshTokenKey, token);
        return;
      }
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      debugPrint('保存 Refresh Token 失败: $e');
    }
  }

  /// 检查是否已登录
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
