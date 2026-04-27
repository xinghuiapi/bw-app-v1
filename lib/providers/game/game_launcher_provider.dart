import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/core/api_response.dart';
import 'package:my_flutter_app/models/game/game_model.dart';
import 'package:my_flutter_app/models/home/home_data.dart';
import 'package:my_flutter_app/services/game/game_service.dart';
import 'package:my_flutter_app/router/app_router.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/providers/auth/auth_provider.dart';
import 'package:my_flutter_app/providers/system/language_provider.dart';

final gameLauncherProvider = Provider((ref) => GameLauncher(ref));

class GameLauncher {
  final Ref _ref;

  GameLauncher(this._ref);

  /// 智能游戏登录，自动切换主/备用接口
  /// 对标 Vue: smartGameLogin
  Future<ApiResponse<GameLoginResponse>> smartGameLogin(
    dynamic id, {
    String lang = 'zh-cn',
    bool useBackup = false,
  }) async {
    try {
      final response = useBackup
          ? await GameService.gameLogin2(id: id, lang: lang)
          : await GameService.gameLogin(id: id, lang: lang);

      if (response.isSuccess && response.data?.url != null) {
        return response;
      } else {
        throw response.msg ?? '游戏登录失败';
      }
    } catch (e) {
      if (!useBackup) {
        // ignore: avoid_print
        print('主游戏接口失败，尝试备用接口: $e');
        return smartGameLogin(id, lang: lang, useBackup: true);
      }
      rethrow;
    }
  }

  Future<void> launchGame(
    BuildContext context,
    dynamic game, {
    bool isCategoryEntry = false,
    String? categoryCode,
    bool? isCategoryResult,
    bool? isHot,
  }) async {
    final authState = _ref.read(authProvider);
    if (!authState.isLoggedIn) {
      // 如果未登录，跳转到登录页
      _ref.read(routerProvider).push('/login');
      return;
    }

    // 显示加载提示
    GlobalLoadingDialog.show(context, message: '正在启动游戏...');

    try {
      final gameId = game.id;
      final gameTitle = game.title ?? '游戏';
      final String code = categoryCode ?? '';

      debugPrint('--- Game Launch Debug ---');
      debugPrint(
        'Game Title: $gameTitle, ID: $gameId, Type: ${game.runtimeType}',
      );
      debugPrint('Category: $code, isEntry: $isCategoryEntry');
      debugPrint('-------------------------');

      bool startWithBackup = false;

      if (game is GameItem) {
        startWithBackup = true;
      } else if (isCategoryResult != null || isHot != null) {
        startWithBackup = (isCategoryResult == false) || (isHot == true);
      } else {
        // 对齐 Vue 逻辑：['game', 'poker', 'fishing'] 分类下使用 gameLogin2
        startWithBackup = [
          'game',
          'poker',
          'fishing',
        ].contains(code.toLowerCase().trim());
      }

      debugPrint('Using Backup Interface: $startWithBackup');

      final lang = _ref.read(languageProvider);
      final apiResponse = await smartGameLogin(
        gameId,
        lang: lang.apiCode,
        useBackup: startWithBackup,
      );

      debugPrint('Game Login Response Success: ${apiResponse.isSuccess}');
      if (apiResponse.isSuccess) {
        debugPrint('Game URL: ${apiResponse.data?.url}');
      } else {
        debugPrint('Game Login Error: ${apiResponse.msg}');
      }

      // 隐藏加载提示
      if (context.mounted) {
        GlobalLoadingDialog.hide(context);
      }

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final loginData = apiResponse.data!;
        if (loginData.url != null) {
          // 跳转到内置 GameViewScreen 展现游戏
          _ref.read(routerProvider).push(
            '/game-view',
            extra: {'url': loginData.url, 'title': gameTitle},
          );
        }
      } else {
        throw apiResponse.msg ?? '获取游戏链接失败';
      }
    } catch (e) {
      // 隐藏加载提示
      if (context.mounted) {
        GlobalLoadingDialog.hide(context);

        // 显示错误提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('游戏启动失败: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      debugPrint('Error launching game: $e');
    }
  }
}
