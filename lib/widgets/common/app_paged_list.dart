import 'package:flutter/material.dart';

import '../../providers/paged_state.dart';
import 'app_empty.dart';
import 'app_error.dart';
import 'app_loading.dart';

class AppPagedList<T> extends StatelessWidget {
  const AppPagedList({
    super.key,
    required this.state,
    required this.itemBuilder,
    this.onLoadMore,
    this.padding,
  });

  final PagedState<T> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (state.items.isEmpty && state.loadMoreError != null) {
      return AppError(message: state.loadMoreError!, onRetry: onLoadMore);
    }
    if (state.items.isEmpty) {
      return const AppEmpty();
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 240 &&
            state.hasMore &&
            !state.isLoadingMore) {
          onLoadMore?.call();
        }
        return false;
      },
      child: ListView.builder(
        padding: padding,
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: AppLoading(),
            );
          }
          return itemBuilder(context, state.items[index], index);
        },
      ),
    );
  }
}
