import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/services/auth_service.dart';
import 'package:my_flutter_app/models/auth_models.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';

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

/// 身份验证提供器
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 监听状态，确保一旦状态被改变就会重新构建
    // 虽然这里没有直接 watch 任何东西，但返回初始状态是必要的
    // _init 是异步的，会稍后触发 state = ... 来更新 UI
    Future.microtask(() => _init());
    return AuthState(isLoading: true);
  }

  Future<void> _init() async {
    final token = await AuthHelper.getToken();
    state = AuthState(isLoggedIn: token != null && token.isNotEmpty, token: token, isLoading: false);
  }

  /// 更新登录状态 (用于外部登录流程，如 Telegram 登录)
  void updateLoginState(String token) {
    state = AuthState(isLoggedIn: true, token: token);
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

/// 身份验证 Provider
final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(AuthNotifier.new);
