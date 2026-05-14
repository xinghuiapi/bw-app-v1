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

  List<FeedbackRecord> get records => data ?? const [];
  bool get hasRemoteRecords => data != null;
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
    types = _fallbackFeedbackTypes;
    isTypesLoading = false;
    typesError = null;
    currentPage = 1;
    lastPage = 1;
    isLoadingMore = false;
    isUploadingImage = false;
    loadMoreError = null;
    notifyListeners();
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
    } catch (exception) {
      error = exception.toString();
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
  FeedbackType(id: -1, title: 'feedback.types.game'),
  FeedbackType(id: -2, title: 'feedback.types.finance'),
  FeedbackType(id: -3, title: 'feedback.types.activity'),
  FeedbackType(id: -4, title: 'feedback.types.accountSecurity'),
  FeedbackType(id: -5, title: 'feedback.types.suggestion'),
];
