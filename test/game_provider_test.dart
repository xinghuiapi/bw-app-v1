import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_project/api/dio_client.dart';
import 'package:flutter_ui_project/models/game/game_models.dart';
import 'package:flutter_ui_project/providers/game/game_provider.dart';
import 'package:flutter_ui_project/services/game/game_service.dart';

void main() {
  test('refreshing categories keeps loaded games for the same category code',
      () async {
    final service = _FakeGameService(
      categories: const [
        [
          GameLobbyCategory(id: 1, title: '真人视讯', code: 'live'),
          GameLobbyCategory(id: 2, title: '体育', code: 'sport'),
        ],
        [
          GameLobbyCategory(id: 1, title: '真人视讯', code: 'live'),
          GameLobbyCategory(id: 2, title: '体育', code: 'sport'),
        ],
      ],
      gamesByCode: const {
        'live': [
          GameProviderItem(id: 11, code: 'ag', title: 'AG视讯'),
        ],
      },
    );
    final provider = GameProvider(service: service);

    await provider.loadCategories();
    await provider.loadGamesByCode('live');
    await provider.loadCategories(refresh: true);

    expect(provider.categories.first.code, 'live');
    expect(provider.categories.first.games, hasLength(1));
    expect(provider.categories.first.games.single.title, 'AG视讯');
  });
}

class _FakeGameService extends GameService {
  _FakeGameService({
    required List<List<GameLobbyCategory>> categories,
    required Map<String, List<GameProviderItem>> gamesByCode,
  })  : _categories = List<List<GameLobbyCategory>>.from(categories),
        _gamesByCode = gamesByCode,
        super(DioClient(dio: Dio()));

  final List<List<GameLobbyCategory>> _categories;
  final Map<String, List<GameProviderItem>> _gamesByCode;
  int _categoryCallCount = 0;

  @override
  Future<List<GameLobbyCategory>> fetchInterfaceClasses({
    bool refresh = false,
  }) async {
    final index = _categoryCallCount.clamp(0, _categories.length - 1);
    _categoryCallCount += 1;
    return _categories[index];
  }

  @override
  Future<List<GameProviderItem>> fetchInterfaceList({
    required String code,
    bool refresh = false,
  }) async {
    return _gamesByCode[code.trim()] ?? const [];
  }
}
