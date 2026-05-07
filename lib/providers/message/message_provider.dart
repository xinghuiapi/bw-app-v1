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
      if (data == null) data = _fallbackMessages;
    } catch (exception) {
      error = exception.toString();
      if (data == null) data = _fallbackMessages;
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

const _fallbackMessages = <UserMessage>[
  UserMessage(
    id: -1,
    title: '充值成功通知',
    content: '您的账户已成功充值 10,000 元，当前余额为 15,200 元。',
    createdAt: '10:30',
    type: 1,
  ),
  UserMessage(
    id: -2,
    title: 'VIP 等级提升',
    content: '恭喜！您的 VIP 等级已提升至 VIP3，快去查看专属特权吧！',
    createdAt: '昨天',
    type: 1,
  ),
  UserMessage(
    id: -3,
    title: '周末狂欢活动开启',
    content: '周末狂欢送不停，登录即送免费抽奖机会，最高可得 8,888 元！',
    createdAt: '04-20',
    type: 2,
  ),
];
