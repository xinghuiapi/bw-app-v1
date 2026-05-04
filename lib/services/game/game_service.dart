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

  Future<GameListPage> fetchGameList({
    required String code,
    required String game,
    int page = 1,
    int size = 20,
    String searchWord = '',
  }) {
    return client.post<GameListPage>(
      ApiEndpoints.gameList,
      data: <String, dynamic>{
        'page': page,
        'size': size,
        'code': code,
        'game': game,
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
}
