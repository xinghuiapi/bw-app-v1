import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/services/game_service.dart';
import 'package:my_flutter_app/models/pagination_state.dart';

part 'hot_games_provider.g.dart';

@riverpod
class HotGames extends _$HotGames {
  @override
  PaginationState<GameItem> build() {
    // 异步触发首次加载
    Future.microtask(() => refresh());
    return const PaginationState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await GameService.getHotGames(page: 1, size: 20, forceRefresh: true);
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        state = PaginationState(
          items: data.data ?? [],
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
      final response = await GameService.getHotGames(page: nextPage, size: 20);
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        state = state.copyWith(
          items: [...state.items, ...(data.data ?? [])],
          currentPage: data.currentPage ?? nextPage,
          lastPage: data.lastPage ?? state.lastPage,
          isMoreLoading: false,
          hasMore: (data.currentPage ?? nextPage) < (data.lastPage ?? state.lastPage),
        );
      } else {
        state = state.copyWith(isMoreLoading: false, error: response.msg);
      }
    } catch (e) {
      state = state.copyWith(isMoreLoading: false, error: e.toString());
    }
  }

  /// 本地更新收藏状态（用于即时反馈）
  void toggleFavoriteLocal(int gameId) {
    final newItems = state.items.map((item) {
      if (item.id == gameId) {
        final currentFavorite = item.isFavorite;
        return GameItem(
          id: item.id,
          title: item.title,
          img: item.img,
          gameCode: item.gameCode,
          favorites: currentFavorite ? 0 : 1, // 切换状态
          isCategoryResult: item.isCategoryResult,
          isHot: item.isHot,
          interfaceTitle: item.interfaceTitle,
          label: item.label,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(items: newItems);
  }
}
