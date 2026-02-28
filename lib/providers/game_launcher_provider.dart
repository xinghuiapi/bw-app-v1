import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../models/api_response.dart';
import '../models/game_model.dart';
import '../models/home_data.dart';
import '../services/game_service.dart';
import '../router/app_router.dart';
import 'auth_provider.dart';
import 'home_provider.dart';
import 'language_provider.dart';

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
    dynamic game, {
    bool isCategoryEntry = false,
    String? categoryCode,
    bool? isCategoryResult,
    bool? isHot,
  }) async {
    final authState = _ref.read(authProvider);
    if (!authState.isLoggedIn) {
      // TODO: Show login modal
      // ignore: avoid_print
      print('User not logged in');
      return;
    }

    try {
      final gameId = game.id;
      final gameTitle = game.title ?? '游戏';
      final String code = categoryCode ?? '';
      
      debugPrint('Launching Game: $gameTitle (ID: $gameId), Category: $code, isEntry: $isCategoryEntry');

      bool startWithBackup = false;

      if (game is GameItem) {
        startWithBackup = true;
      } else if (isCategoryResult != null || isHot != null) {
        startWithBackup = (isCategoryResult == false) || (isHot == true);
      } else {
        // 对齐 Vue 逻辑：['game', 'poker', 'fishing'] 分类下使用 gameLogin2
        startWithBackup = ['game', 'poker', 'fishing'].contains(code.toLowerCase().trim());
      }

      final lang = _ref.read(languageProvider);
      final apiResponse = await smartGameLogin(gameId, lang: lang, useBackup: startWithBackup);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final loginData = apiResponse.data!;
        if (loginData.url != null) {
          // 跳转到内部 GameViewScreen 展现游戏
          AppRouter.router.push('/game-view', extra: {
            'url': loginData.url,
            'title': gameTitle,
          });
        }
      } else {
        throw apiResponse.msg ?? '获取游戏链接失败';
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error launching game: $e');
      // TODO: Show error notification
    }
  }
}
