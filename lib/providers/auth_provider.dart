import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/auth_helper.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';
import '../models/api_response.dart';

/// 身份验证状态类
class AuthState {
  final bool isLoggedIn;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isLoggedIn = false,
    this.token,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 身份验证提供者
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return AuthState();
  }

  Future<void> _init() async {
    final token = await AuthHelper.getToken();
    state = AuthState(isLoggedIn: token != null && token.isNotEmpty, token: token);
  }

  /// 登录
  Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await AuthService.login(request);
    
    if (response.isSuccess && response.data != null) {
      final token = response.data!.accessToken;
      await AuthHelper.setToken(token);
      state = AuthState(isLoggedIn: true, token: token);
    } else {
      state = state.copyWith(isLoading: false, error: response.msg);
    }
    
    return response;
  }

  /// 注册
  Future<ApiResponse<AuthResponseData>> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final response = await AuthService.register(request);
    
    if (response.isSuccess && response.data != null) {
      final token = response.data!.accessToken;
      await AuthHelper.setToken(token);
      state = AuthState(isLoggedIn: true, token: token);
    } else {
      state = state.copyWith(isLoading: false, error: response.msg);
    }
    
    return response;
  }

  /// 退出登录
  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (e) {
      debugPrint('Logout API error: $e');
    } finally {
      await AuthHelper.clearToken();
      state = AuthState(isLoggedIn: false, token: null);
    }
  }

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
