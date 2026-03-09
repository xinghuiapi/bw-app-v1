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

class GameListNotifier extends Notifier<GameListPaginationState> {
  final Map<String, dynamic> arg;
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
      final gameCode = arg['game'] as String;
      final typeCode = arg['code'] as String;
      final pageSize = arg['size'] as int? ?? 30;
      final nextPage = currentState.currentPage + 1;

      final response = await GameService.getSubGameList(
        gameCode: gameCode,
        typeCode: typeCode,
        page: nextPage,
        size: pageSize,
      );

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
      state = currentState.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gameCode = arg['game'] as String;
      final typeCode = arg['code'] as String;
      final pageSize = arg['size'] as int? ?? 30;
      
      final response = await GameService.getSubGameList(
        gameCode: gameCode,
        typeCode: typeCode,
        page: 1,
        size: pageSize,
      );

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
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final gameListProvider = NotifierProvider.autoDispose.family<GameListNotifier, GameListPaginationState, Map<String, dynamic>>((arg) {
  return GameListNotifier(arg);
});
