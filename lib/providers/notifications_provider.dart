import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/user_models.dart';
import 'package:my_flutter_app/services/user_service.dart';

class NotificationsState {
  final List<UserMessage> messages;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  NotificationsState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  NotificationsState copyWith({
    List<UserMessage>? messages,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return NotificationsState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  @override
  NotificationsState build() => NotificationsState();

  Future<void> fetchMessages({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    if (refresh) {
      state = state.copyWith(isLoading: true, page: 1, messages: [], hasMore: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    final response = await UserService.getUserMessages(page: refresh ? 1 : state.page);

    if (response.isSuccess) {
      final newMessages = response.data ?? [];
      state = state.copyWith(
        messages: refresh ? newMessages : [...state.messages, ...newMessages],
        isLoading: false,
        page: (refresh ? 1 : state.page) + 1,
        hasMore: newMessages.length >= 20, // 假设每页 20 条
      );
    } else {
      state = state.copyWith(isLoading: false, error: response.msg);
    }
  }

  Future<void> markAsRead(int id) async {
    final response = await UserService.markMessageAsRead(id);
    if (response.isSuccess) {
      state = state.copyWith(
        messages: state.messages.map((m) {
          if (m.id == id) {
            return m.copyWith(type: 2); // 2 为已读
          }
          return m;
        }).toList(),
      );
    } else {
      state = state.copyWith(error: response.msg);
    }
  }

  Future<void> markAllAsRead() async {
    final response = await UserService.markAllMessagesAsRead();
    if (response.isSuccess) {
      state = state.copyWith(
        messages: state.messages.map((m) => m.copyWith(type: 2)).toList(),
      );
    } else {
      state = state.copyWith(error: response.msg);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final notificationsProvider = NotifierProvider.autoDispose<NotificationsNotifier, NotificationsState>(NotificationsNotifier.new);
