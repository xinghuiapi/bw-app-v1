import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/home/home_data.dart';
import 'package:my_flutter_app/services/game/game_service.dart';
import 'package:my_flutter_app/models/core/pagination_state.dart';

part 'favorite_games_provider.g.dart';

@Riverpod(keepAlive: true)
class FavoriteGames extends _$FavoriteGames {
  @override
  PaginationState<GameItem> build() {
    // 异步触发首次加载
    Future.microtask(() => refresh());
    return const PaginationState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await GameService.getFavoriteGames(
        page: 1,
        size: 20,
        forceRefresh: true,
      );
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        // 过滤出响应里 favorites (Boolean): true 的游戏
        final filteredItems = (data.data ?? [])
            .where((item) => item.isFavorite)
            .toList();

        state = PaginationState(
          items: filteredItems,
          currentPage: data.currentPage ?? 1,
          lastPage: data.lastPage ?? 1,
          isLoading: false,
          hasMore: (data.currentPage ?? 1) < (data.lastPage ?? 1),
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.msg);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isMoreLoading || !state.hasMore) return;

    state = state.copyWith(isMoreLoading: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await GameService.getFavoriteGames(
        page: nextPage,
        size: 20,
      );
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        // 过滤出响应里 favorites (Boolean): true 的游戏
        final filteredItems = (data.data ?? [])
            .where((item) => item.isFavorite)
            .toList();

        state = state.copyWith(
          items: [...state.items, ...filteredItems],
          currentPage: data.currentPage ?? nextPage,
          lastPage: data.lastPage ?? state.lastPage,
          isMoreLoading: false,
          hasMore:
              (data.currentPage ?? nextPage) <
              (data.lastPage ?? state.lastPage),
        );
      } else {
        state = state.copyWith(isMoreLoading: false, error: response.msg);
      }
    } catch (e) {
      state = state.copyWith(isMoreLoading: false, error: e.toString());
    }
  }

  /// 本地更新收藏状态（取消收藏时从列表中移除）
  void toggleFavoriteLocal(int gameId) {
    final currentItems = [...state.items];
    final index = currentItems.indexWhere((item) => item.id == gameId);
    if (index != -1) {
      currentItems.removeAt(index);
      state = state.copyWith(items: currentItems);
    }
  }
}
