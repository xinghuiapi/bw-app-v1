import '../../models/common/upload_models.dart';
import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/user/user_models.dart';
import '../../services/user/user_service.dart';
import '../base_provider.dart';

class FeedbackProvider extends BaseProvider<List<FeedbackRecord>> {
  FeedbackProvider({UserService? service})
      : _service = service ?? UserService(DioClient());

  UserService _service;
  List<FeedbackType> types = _fallbackFeedbackTypes;
  bool isTypesLoading = false;
  String? typesError;
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;
  bool isUploadingImage = false;
  String? loadMoreError;

  List<FeedbackRecord> get records => data ?? _fallbackFeedbackRecords;
  bool get hasRemoteRecords => data != null;
  bool get hasMore => currentPage < lastPage;

  void bindClient(DioClient client) {
    _service = UserService(client);
  }

  Future<void> loadTypes({bool refresh = false}) async {
    if (isTypesLoading) return;
    if (!refresh && types.isNotEmpty && types != _fallbackFeedbackTypes) return;

    isTypesLoading = true;
    typesError = null;
    notifyListeners();

    try {
      final remoteTypes = await _service.fetchFeedbackTypes();
      if (remoteTypes.isNotEmpty) types = remoteTypes;
      typesError = null;
    } on ApiException catch (exception) {
      typesError = exception.message;
      if (types.isEmpty) types = _fallbackFeedbackTypes;
    } catch (exception) {
      typesError = exception.toString();
      if (types.isEmpty) types = _fallbackFeedbackTypes;
    } finally {
      isTypesLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitFeedback(SubmitFeedbackRequest request) async {
    if (isSubmitting) return;
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _service.submitFeedback(request);
      await loadRecords(refresh: true);
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<UploadImageResult> uploadFeedbackImage({
    required List<int> bytes,
    required String filename,
  }) async {
    if (isUploadingImage) {
      return const UploadImageResult();
    }
    isUploadingImage = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.uploadImage(
        bytes: bytes,
        filename: filename,
        name: 'feedback',
      );
      error = null;
      return result;
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } catch (exception) {
      error = exception.toString();
      rethrow;
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> loadRecords({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;

    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    error = null;
    notifyListeners();

    try {
      final page = await _service.fetchFeedbackRecords(page: 1);
      data = page.data;
      currentPage = page.currentPage ?? 1;
      lastPage = page.lastPage ?? 1;
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      data ??= _fallbackFeedbackRecords;
    } catch (exception) {
      error = exception.toString();
      data ??= _fallbackFeedbackRecords;
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreRecords() async {
    if (isLoadingMore || isLoading || !hasMore) return;
    isLoadingMore = true;
    loadMoreError = null;
    notifyListeners();

    try {
      final page = await _service.fetchFeedbackRecords(page: currentPage + 1);
      data = [...records, ...page.data];
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
}

const _fallbackFeedbackTypes = <FeedbackType>[
  FeedbackType(id: -1, title: '游戏问题'),
  FeedbackType(id: -2, title: '充提问题'),
  FeedbackType(id: -3, title: '活动问题'),
  FeedbackType(id: -4, title: '账户安全'),
  FeedbackType(id: -5, title: '其他建议'),
];

const _fallbackFeedbackRecords = <FeedbackRecord>[
  FeedbackRecord(
    id: -1,
    title: '游戏问题',
    content: '游戏大厅加载速度有时候比较慢，希望能优化一下。',
    createdAt: '2024-04-20 14:30',
  ),
  FeedbackRecord(
    id: -2,
    title: '其他建议',
    content: '建议增加夜间模式，晚上玩的时候太刺眼了。',
    reply: '感谢您的建议，我们会持续优化体验。',
    createdAt: '2024-04-15 09:15',
    updatedAt: '2024-04-15 10:20',
  ),
];
