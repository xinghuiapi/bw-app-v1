class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final bool isMoreLoading;
  final String? error;
  final bool hasMore;

  const PaginationState({
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoading = false,
    this.isMoreLoading = false,
    this.error,
    this.hasMore = false,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    bool? isMoreLoading,
    String? error,
    bool? hasMore,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
