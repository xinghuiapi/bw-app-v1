import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/user.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';

import 'package:my_flutter_app/services/user_service.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';

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
      // 对接原项目接口 /token/user
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
      // 对接原项目接口 /game/all_trans
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

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 切换收藏状态
  /// [gameId] 游戏 ID
  /// [status] 目标状态：1 为收藏，0 为取消收藏
  Future<bool> toggleFavorite(int gameId, int status) async {
    try {
      final response = await UserService.toggleGameFavorite(gameId, status);
      if (response.isSuccess) {
        // 收藏成功后不需要刷新整个用户信息，只需返回成功即可。
        // UI 层负责更新本地状态以保持流畅性。
        return true;
      } else {
        ToastUtils.showError(response.msg ?? '操作失败');
        return false;
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      return false;
    }
  }
}

/// 用户 Provider
final userProvider = NotifierProvider<UserNotifier, UserState>(UserNotifier.new);
