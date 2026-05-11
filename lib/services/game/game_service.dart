import '../../config/api_endpoints.dart';
import '../../models/game/game_models.dart';
import '../base_service.dart';

class GameService extends BaseService {
  const GameService(super.client);

  Future<List<GameLobbyCategory>> fetchInterfaceClasses() {
    return client.post<List<GameLobbyCategory>>(
      ApiEndpoints.interfaceClass,
      decoder: (json) {
        if (json is! List) return const [];
        return json
            .whereType<Map>()
            .map((item) =>
                GameLobbyCategory.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.title.isNotEmpty && item.code.isNotEmpty)
            .toList();
      },
    );
  }

  Future<List<GameProviderItem>> fetchInterfaceList({required String code}) {
    return client.post<List<GameProviderItem>>(
      ApiEndpoints.interfaceList,
      data: code.trim().isEmpty ? null : <String, dynamic>{'code': code.trim()},
      decoder: (json) {
        if (json is! List) return const [];
        final items = json
            .whereType<Map>()
            .map((item) =>
                GameProviderItem.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.title.isNotEmpty)
            .toList();
        final normalizedCode = code.trim().toLowerCase();
        final byType = items
            .where((item) =>
                (item.type ?? '').trim().toLowerCase() == normalizedCode)
            .toList();
        return byType.isEmpty ? items : byType;
      },
    );
  }

  Future<List<RecommendedGame>> fetchRecommendedGames() {
    return client.post<List<RecommendedGame>>(
      ApiEndpoints.interfaceRecommend,
      decoder: (json) {
        if (json is! List) return const [];
        return json
            .whereType<Map>()
            .map((item) =>
                RecommendedGame.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.title.isNotEmpty)
            .take(30)
            .toList();
      },
    );
  }

  Future<List<RecommendedGame>> fetchRecommendedGamesFromInterfaceList() {
    return client.post<List<RecommendedGame>>(
      ApiEndpoints.interfaceList,
      decoder: (json) {
        if (json is! List) return const [];
        return json
            .whereType<Map>()
            .map((item) =>
                RecommendedGame.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.title.isNotEmpty && _hasRecoLabel(item.label))
            .take(30)
            .toList();
      },
    );
  }

  bool _hasRecoLabel(dynamic label) {
    if (label == null) return false;
    if (label is List) {
      return label.map((item) => item.toString().trim()).contains('reco');
    }
    final raw = label.toString().replaceAll('`', '"').trim();
    if (raw.isEmpty) return false;
    final normalized = raw.replaceAll(RegExp(r'''^[\['"]+|[\]'\"]+$'''), '');
    return normalized
        .split(',')
        .map((item) =>
            item.trim().replaceAll(RegExp(r'''^[\['"]+|[\]'\"]+$'''), ''))
        .contains('reco');
  }

  Future<GameListPage> fetchGameList({
    required String code,
    required String game,
    int page = 1,
    int size = 20,
    String searchWord = '',
    String label = '',
  }) {
    return client.post<GameListPage>(
      ApiEndpoints.gameList,
      data: <String, dynamic>{
        'page': page,
        'size': size,
        if (code.trim().isNotEmpty) 'code': code.trim(),
        if (game.trim().isNotEmpty) 'game': game.trim(),
        if (label.trim().isNotEmpty) 'label': label.trim(),
        if (searchWord.trim().isNotEmpty) 'search_word': searchWord.trim(),
      },
      decoder: (json) {
        if (json is Map) {
          return GameListPage.fromJson(Map<String, dynamic>.from(json));
        }
        return const GameListPage();
      },
    );
  }

  Future<void> setGameFavorite({required int id, required bool favorited}) {
    return client.post<void>(
      ApiEndpoints.gameFavorite,
      data: <String, dynamic>{'id': id, 'status': favorited ? 1 : 0},
      decoder: (_) {},
    );
  }

  Future<GameLaunchResult> launchGame({required int id}) {
    return client.post<GameLaunchResult>(
      ApiEndpoints.gameLogin,
      data: <String, dynamic>{'id': id, 'mobile': 1},
      decoder: (json) {
        if (json is Map) {
          return GameLaunchResult.fromJson(Map<String, dynamic>.from(json));
        }
        return const GameLaunchResult();
      },
    );
  }
}
