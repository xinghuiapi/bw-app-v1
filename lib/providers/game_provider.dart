import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/home_data.dart';
import '../services/game_service.dart';

class GameListPaginationState {
  final List<GameItem> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  GameListPaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.lastPage = 0,
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  GameListPaginationState copyWith({
    List<GameItem>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return GameListPaginationState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class GameListParams {
  final String game;
  final String code;
  final int size;

  const GameListParams({
    required this.game,
    required this.code,
    this.size = 30,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameListParams &&
          runtimeType == other.runtimeType &&
          game == other.game &&
          code == other.code &&
          size == other.size;

  @override
  int get hashCode => game.hashCode ^ code.hashCode ^ size.hashCode;
}

class GameListNotifier extends Notifier<GameListPaginationState> {
  GameListParams get params {
    final arg = this.arg;
    if (arg is GameListParams) return arg;
    // 兼容旧的 Map 传参
    final map = arg as Map<String, dynamic>;
    return GameListParams(
      game: map['game'] as String,
      code: map['code'] as String,
      size: map['size'] as int? ?? 30,
    );
  }
  
  final dynamic arg;
  GameListNotifier(this.arg);

  @override
  GameListPaginationState build() {
    // 异步触发加载
    Future.microtask(() => refresh());
    return GameListPaginationState(isLoading: true);
  }

  Future<void> loadMore() async {
    final currentState = state;
    
    // 如果正在加载，或者已经没有更多数据，则返回
    if (currentState.isLoading || !currentState.hasMore) return;

    state = currentState.copyWith(isLoading: true, error: null);

    try {
      final p = params;
      final nextPage = currentState.currentPage + 1;

      final response = await GameService.getSubGameList(
        gameCode: p.game,
        typeCode: p.code,
        page: nextPage,
        size: p.size,
      );

      if (!ref.mounted) return;

      if (response.isSuccess && response.data != null) {
        final newData = response.data!;
        final List<GameItem> newItems = [...currentState.items, ...(newData.data ?? [])];
        
        final currentPage = newData.currentPage ?? nextPage;
        final lastPage = newData.lastPage ?? currentPage;

        state = currentState.copyWith(
          items: newItems,
          currentPage: currentPage,
          lastPage: lastPage,
          isLoading: false,
          hasMore: currentPage < lastPage,
        );
      } else {
        state = currentState.copyWith(
          isLoading: false,
          error: response.msg,
        );
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final p = params;
      
      final response = await GameService.getSubGameList(
        gameCode: p.game,
        typeCode: p.code,
        page: 1,
        size: p.size,
      );

      if (!ref.mounted) return;

      if (response.isSuccess && response.data != null) {
        final newData = response.data!;
        final currentPage = newData.currentPage ?? 1;
        final lastPage = newData.lastPage ?? currentPage;

        state = GameListPaginationState(
          items: newData.data ?? [],
          currentPage: currentPage,
          lastPage: lastPage,
          isLoading: false,
          hasMore: currentPage < lastPage,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.msg,
        );
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 本地更新收藏状态（用于即时反馈）
  void toggleFavoriteLocal(int gameId) {
    final newItems = state.items.map((item) {
      if (item.id == gameId) {
        // 由于 GameItem 是 immutable，需要重新构造
        final currentFavorite = item.isFavorite;
        return GameItem(
          id: item.id,
          title: item.title,
          img: item.img,
          gameCode: item.gameCode,
          favorites: currentFavorite ? 0 : 1, // 切换状态
          isCategoryResult: item.isCategoryResult,
          isHot: item.isHot,
        );
      }
      return item;
    }).toList();
    
    state = state.copyWith(items: newItems);
  }
}

final gameListProvider = NotifierProvider.family<GameListNotifier, GameListPaginationState, dynamic>((arg) {
  return GameListNotifier(arg);
});
