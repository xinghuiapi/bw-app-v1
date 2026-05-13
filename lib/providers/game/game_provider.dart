import 'package:flutter/foundation.dart';

import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/game/game_models.dart';
import '../../services/game/game_service.dart';
import '../base_provider.dart';

class GameProvider extends BaseProvider<List<GameLobbyCategory>> {
  GameProvider({GameService? service})
      : _service = service ?? GameService(DioClient());

  GameService _service;
  final Set<String> _loadingCodes = <String>{};
  final Set<String> _loadedCodes = <String>{};

  List<RecommendedGame> recommendedGames = const [];
  bool isRecommendedLoading = false;
  bool hasRecommendedLoaded = false;
  String? recommendedError;

  List<GameItem> hotGames = const [];
  bool isHotGamesLoading = false;
  bool hasHotGamesLoaded = false;
  String? hotGamesError;

  GameListPage subListPage = const GameListPage();
  bool isSubListLoading = false;
  bool isSubListLoadingMore = false;
  bool hasSubListLoaded = false;
  String? subListError;
  String _subListCode = '';
  String _subListGame = '';
  String _subListSearchWord = '';
  int _subListSize = 24;
  int _subListRequestSerial = 0;
  int? favoritingGameId;
  int? launchingGameId;
  String? launchError;

  List<GameLobbyCategory> get categories => data ?? const [];

  void resetForLanguageChange() {
    data = const [];
    error = null;
    _loadingCodes.clear();
    _loadedCodes.clear();
    recommendedGames = const [];
    isRecommendedLoading = false;
    hasRecommendedLoaded = false;
    recommendedError = null;
    hotGames = const [];
    isHotGamesLoading = false;
    hasHotGamesLoaded = false;
    hotGamesError = null;
    subListPage = const GameListPage();
    isSubListLoading = false;
    isSubListLoadingMore = false;
    hasSubListLoaded = false;
    subListError = null;
    _subListCode = '';
    _subListGame = '';
    _subListSearchWord = '';
    favoritingGameId = null;
    launchingGameId = null;
    launchError = null;
    notifyListeners();
  }

  bool get hasMoreSubList {
    final currentPage = subListPage.currentPage ?? 0;
    final lastPage = subListPage.lastPage ?? currentPage;
    return currentPage < lastPage;
  }

  bool isCurrentSubList({
    required String code,
    required String game,
    String? searchWord,
  }) {
    final isSameBase =
        _subListCode == code.trim() && _subListGame == game.trim();
    if (searchWord == null) return isSameBase;
    return isSameBase && _subListSearchWord == searchWord.trim();
  }

  void bindClient(DioClient client) {
    _service = GameService(client);
  }

  bool isCategoryLoading(String code) => _loadingCodes.contains(code);

  bool hasCategoryLoaded(String code) => _loadedCodes.contains(code.trim());

  Future<void> loadRecommendedGames({bool refresh = false}) async {
    if (isRecommendedLoading ||
        (!refresh && hasRecommendedLoaded && recommendedGames.isNotEmpty)) {
      return;
    }

    isRecommendedLoading = true;
    recommendedError = null;
    notifyListeners();

    try {
      recommendedGames = await _service.fetchRecommendedGames();
      if (recommendedGames.isEmpty) {
        recommendedGames =
            await _service.fetchRecommendedGamesFromInterfaceList();
      }
      hasRecommendedLoaded = true;
      recommendedError = null;
    } on ApiException catch (exception) {
      recommendedError = exception.message;
      try {
        recommendedGames =
            await _service.fetchRecommendedGamesFromInterfaceList();
        recommendedError = null;
      } catch (_) {}
      hasRecommendedLoaded = true;
    } catch (exception) {
      recommendedError = exception.toString();
      try {
        recommendedGames =
            await _service.fetchRecommendedGamesFromInterfaceList();
        recommendedError = null;
      } catch (_) {}
      hasRecommendedLoaded = true;
    } finally {
      isRecommendedLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHotGames({bool refresh = false}) async {
    if (isHotGamesLoading ||
        (!refresh && hasHotGamesLoaded && hotGames.isNotEmpty)) {
      return;
    }

    isHotGamesLoading = true;
    hotGamesError = null;
    notifyListeners();

    try {
      final page = await _service.fetchGameList(
        code: '',
        game: '',
        page: 1,
        size: 30,
        label: 'hot',
      );
      hotGames =
          page.data.where((item) => item.title?.isNotEmpty == true).toList();
      hasHotGamesLoaded = true;
      hotGamesError = null;
    } on ApiException catch (exception) {
      hotGamesError = exception.message;
      hasHotGamesLoaded = true;
    } catch (exception) {
      hotGamesError = exception.toString();
      hasHotGamesLoaded = true;
    } finally {
      isHotGamesLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories({bool refresh = false}) async {
    if (isLoading || (!refresh && categories.isNotEmpty)) return;
    isLoading = true;
    error = null;
    debugPrint('[game] load interface/class');
    notifyListeners();

    try {
      data = await _service.fetchInterfaceClasses();
      error = null;
      debugPrint('[game] interface/class parsed=${categories.length}');
    } on ApiException catch (exception) {
      error = exception.message;
      debugPrint('[game] interface/class api error=$error');
    } catch (exception) {
      error = exception.toString();
      debugPrint('[game] interface/class error=$error');
    } finally {
      isLoading = false;
      notifyListeners();
    }

    if (categories.isNotEmpty) {
      loadGamesByCode(categories.first.code);
    }
  }

  Future<void> loadGamesByCode(String code) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty || _loadingCodes.contains(normalizedCode)) {
      return;
    }
    _loadingCodes.add(normalizedCode);
    debugPrint('[game] load interface/list code=$normalizedCode');
    notifyListeners();

    try {
      final games = await _service.fetchInterfaceList(code: normalizedCode);
      data = categories
          .map((category) => category.code == normalizedCode
              ? category.copyWith(games: games)
              : category)
          .toList();
      _loadedCodes.add(normalizedCode);
      error = null;
      debugPrint(
          '[game] interface/list code=$normalizedCode parsed=${games.length}');
    } on ApiException catch (exception) {
      error = exception.message;
      debugPrint('[game] interface/list code=$normalizedCode api error=$error');
      _setCategoryGames(normalizedCode, const []);
      _loadedCodes.add(normalizedCode);
    } catch (exception) {
      error = exception.toString();
      debugPrint('[game] interface/list code=$normalizedCode error=$error');
      _setCategoryGames(normalizedCode, const []);
      _loadedCodes.add(normalizedCode);
    } finally {
      _loadingCodes.remove(normalizedCode);
      notifyListeners();
    }
  }

  void _setCategoryGames(String code, List<GameProviderItem> games) {
    data = categories
        .map((category) =>
            category.code == code ? category.copyWith(games: games) : category)
        .toList();
  }

  Future<void> loadGameSubList({
    required String code,
    required String game,
    int page = 1,
    int size = 24,
    String searchWord = '',
    bool refresh = true,
  }) async {
    final normalizedCode = code.trim();
    final normalizedGame = game.trim();
    final normalizedSearchWord = searchWord.trim();
    final isSameQuery = isCurrentSubList(
          code: normalizedCode,
          game: normalizedGame,
        ) &&
        _subListSearchWord == normalizedSearchWord;
    if ((isSubListLoading || isSubListLoadingMore) && isSameQuery) return;
    if (normalizedCode.isEmpty || normalizedGame.isEmpty) {
      subListPage = const GameListPage();
      hasSubListLoaded = false;
      subListError = null;
      notifyListeners();
      return;
    }

    _subListCode = normalizedCode;
    _subListGame = normalizedGame;
    _subListSearchWord = normalizedSearchWord;
    _subListSize = size;
    final requestSerial = ++_subListRequestSerial;

    isSubListLoading = true;
    subListError = null;
    if (refresh) {
      hasSubListLoaded = false;
      subListPage = const GameListPage();
    }
    notifyListeners();

    try {
      final nextPage = await _service.fetchGameList(
        code: normalizedCode,
        game: normalizedGame,
        page: page,
        size: size,
        searchWord: normalizedSearchWord,
      );
      if (requestSerial != _subListRequestSerial) return;
      subListPage = nextPage;
      hasSubListLoaded = true;
      subListError = null;
    } on ApiException catch (exception) {
      if (requestSerial != _subListRequestSerial) return;
      subListError = exception.message;
    } catch (exception) {
      if (requestSerial != _subListRequestSerial) return;
      subListError = exception.toString();
    } finally {
      if (requestSerial == _subListRequestSerial) {
        isSubListLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMoreGameSubList() async {
    if (isSubListLoading || isSubListLoadingMore || !hasMoreSubList) return;
    if (_subListCode.isEmpty || _subListGame.isEmpty) return;

    final currentPage = subListPage.currentPage ?? 1;
    final requestSerial = ++_subListRequestSerial;
    isSubListLoadingMore = true;
    subListError = null;
    notifyListeners();

    try {
      final nextPage = await _service.fetchGameList(
        code: _subListCode,
        game: _subListGame,
        page: currentPage + 1,
        size: _subListSize,
        searchWord: _subListSearchWord,
      );
      if (requestSerial != _subListRequestSerial) return;
      subListPage = nextPage.copyWith(
        data: <GameItem>[
          ...subListPage.data,
          ...nextPage.data,
        ],
      );
      hasSubListLoaded = true;
      subListError = null;
    } on ApiException catch (exception) {
      if (requestSerial != _subListRequestSerial) return;
      subListError = exception.message;
    } catch (exception) {
      if (requestSerial != _subListRequestSerial) return;
      subListError = exception.toString();
    } finally {
      if (requestSerial == _subListRequestSerial) {
        isSubListLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleGameFavorite(GameItem game) async {
    final id = game.id;
    if (id <= 0 || favoritingGameId == id) return;

    final next = !game.isFavorite;
    favoritingGameId = id;
    subListError = null;
    notifyListeners();

    try {
      await _service.setGameFavorite(id: id, favorited: next);
      subListPage = subListPage.copyWith(
        data: subListPage.data
            .map(
                (item) => item.id == id ? item.copyWith(favorited: next) : item)
            .toList(),
      );
    } on ApiException catch (exception) {
      subListError = exception.message;
      rethrow;
    } catch (exception) {
      subListError = exception.toString();
      rethrow;
    } finally {
      if (favoritingGameId == id) favoritingGameId = null;
      notifyListeners();
    }
  }

  Future<GameLaunchResult> launchGame(GameLaunchTarget target) async {
    if (target.id <= 0) return const GameLaunchResult();
    if (launchingGameId == target.id) return const GameLaunchResult();

    launchingGameId = target.id;
    launchError = null;
    notifyListeners();

    try {
      final result = await _service.launchGame(id: target.id);
      launchError = null;
      return result;
    } on ApiException catch (exception) {
      launchError = exception.message;
      rethrow;
    } catch (exception) {
      launchError = exception.toString();
      rethrow;
    } finally {
      if (launchingGameId == target.id) launchingGameId = null;
      notifyListeners();
    }
  }
}
