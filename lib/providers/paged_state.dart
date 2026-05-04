class PagedState<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;

  const PagedState({
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  PagedState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadMoreError,
  }) {
    return PagedState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}
