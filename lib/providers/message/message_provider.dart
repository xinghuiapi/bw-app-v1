import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/user/user_models.dart';
import '../../services/user/user_service.dart';
import '../base_provider.dart';

class MessageProvider extends BaseProvider<List<UserMessage>> {
  MessageProvider({UserService? service})
      : _service = service ?? UserService(DioClient());

  UserService _service;
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;
  String? loadMoreError;

  List<UserMessage> get messages => data ?? const [];
  int get unreadCount => messages.where((item) => !item.isRead).length;
  bool get hasMore => currentPage < lastPage;

  void bindClient(DioClient client) {
    _service = UserService(client);
  }

  void resetForLanguageChange() {
    data = null;
    error = null;
    isLoading = false;
    isRefreshing = false;
    isSubmitting = false;
    currentPage = 1;
    lastPage = 1;
    isLoadingMore = false;
    loadMoreError = null;
    notifyListeners();
  }

  Future<void> loadMessages({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;
    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    error = null;
    notifyListeners();

    try {
      final page = await _service.fetchMessages(page: 1);
      data = page.data;
      currentPage = page.currentPage ?? 1;
      lastPage = page.lastPage ?? 1;
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (exception) {
      error = exception.toString();
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || isLoading || !hasMore) return;
    isLoadingMore = true;
    loadMoreError = null;
    notifyListeners();

    try {
      final page = await _service.fetchMessages(page: currentPage + 1);
      data = [...messages, ...page.data];
      currentPage = page.currentPage ?? currentPage + 1;
      lastPage = page.lastPage ?? lastPage;
    } on ApiException catch (exception) {
      loadMoreError = exception.message;
    } catch (exception) {
      loadMoreError = exception.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markRead(UserMessage message) async {
    if (message.isRead) return;
    await _service.markMessageRead(message.id);
    data = messages
        .map((item) => item.id == message.id
            ? UserMessage(
                id: item.id,
                title: item.title,
                content: item.content,
                createdAt: item.createdAt,
                type: 2,
              )
            : item)
        .toList();
    notifyListeners();
  }
}
