import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import 'auth_provider.dart';

/// 用户状态
class UserState {
  final User? user;
  final bool isLoading;
  final bool isBalanceLoading;
  final bool isAllTransLoading;
  final String? error;

  UserState({
    this.user,
    this.isLoading = false,
    this.isBalanceLoading = false,
    this.isAllTransLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    bool? isBalanceLoading,
    bool? isAllTransLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isBalanceLoading: isBalanceLoading ?? this.isBalanceLoading,
      isAllTransLoading: isAllTransLoading ?? this.isAllTransLoading,
      error: error ?? this.error,
    );
  }
}

/// 用户信息 Notifier
class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    // 监听登录状态
    final authState = ref.watch(authProvider);

    if (authState.isLoggedIn) {
      // 登录后自动获取用户信息
      Future.microtask(() => fetchUserInfo());
    }

    return UserState();
  }

  /// 获取用户信息
  Future<void> fetchUserInfo() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      // ⚠️ 修复：对接原项目接口 /token/user
      debugPrint('Fetching user info from /token/user...');
      final response = await api.post('/token/user');
      debugPrint('User info response: ${response.data}');
      
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        // 原项目返回的可能是数组或对象，如果是数组则取第一个
        final data = apiResponse.data;
        final userData = data is List 
            ? (data.isNotEmpty ? data[0] as Map<String, dynamic> : null)
            : data as Map<String, dynamic>;
            
        if (userData == null) {
          state = state.copyWith(isLoading: false, error: '获取用户信息为空');
          return;
        }

        debugPrint('Parsing user data: $userData');
        try {
          final user = User.fromJson(userData);
          state = state.copyWith(
            user: user,
            isLoading: false,
          );
          debugPrint('User data parsed successfully: ${user.username}');
        } catch (e, stack) {
          debugPrint('Error parsing User model: $e');
          debugPrint('Stack trace: $stack');
          state = state.copyWith(
            isLoading: false,
            error: '数据解析失败: $e',
          );
        }
      } else {
        debugPrint('User info failed: ${apiResponse.msg}');
        state = state.copyWith(
          isLoading: false,
          error: apiResponse.msg ?? '获取用户信息失败',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 刷新余额
  Future<void> refreshBalance() async {
    if (state.isBalanceLoading) return;
    
    state = state.copyWith(isBalanceLoading: true);
    await fetchUserInfo();
    state = state.copyWith(isBalanceLoading: false);
  }

  /// 一键回收余额
  Future<void> allTrans() async {
    if (state.isAllTransLoading) return;
    
    state = state.copyWith(isAllTransLoading: true);
    try {
      // ⚠️ 修复：对接原项目接口 /game/all_trans
      final response = await api.post('/game/all_trans');
      final apiResponse = ApiResponse.fromJson(response.data, (json) => json);
      
      if (apiResponse.isSuccess) {
        // 回收成功后刷新用户信息获取最新余额
        await fetchUserInfo();
      }
    } catch (e) {
      debugPrint('Error during allTrans: $e');
    } finally {
      state = state.copyWith(isAllTransLoading: false);
    }
  }
}

/// 用户信息提供者
final userProvider = NotifierProvider<UserNotifier, UserState>(() {
  return UserNotifier();
});
