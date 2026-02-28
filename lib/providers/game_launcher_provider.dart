import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/dio_client.dart';
import '../models/api_response.dart';
import '../models/game_model.dart';
import 'auth_provider.dart';

final gameLauncherProvider = Provider((ref) => GameLauncher(ref));

class GameLauncher {
  final Ref _ref;

  GameLauncher(this._ref);

  Future<void> launchGame(dynamic game, {bool isCategoryEntry = false, String? categoryCode}) async {
    final authState = _ref.read(authProvider);
    if (!authState.isLoggedIn) {
      // TODO: Show login modal
      // ignore: avoid_print
      print('User not logged in');
      return;
    }

    try {
      final gameId = game.id;
      final String code = categoryCode ?? '';
      
      // 根据分类类型判断使用哪个接口
      // 对标 Vue: const shouldUseGameLogin2 = !isCategoryEntry && ['game', 'poker', 'fishing'].includes(currentCategoryCode)
      final bool shouldUseGameLogin2 = !isCategoryEntry && ['game', 'poker', 'fishing'].contains(code);
      final String endpoint = shouldUseGameLogin2 ? '/game/login2' : '/game/login';

      final response = await api.post(endpoint, data: {
        'id': gameId,
        'lang': 'zh-cn', // 默认中文
      });

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final loginData = GameLoginResponse.fromJson(apiResponse.data!);
        if (loginData.url != null) {
          final Uri url = Uri.parse(loginData.url!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch ${loginData.url}';
          }
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
