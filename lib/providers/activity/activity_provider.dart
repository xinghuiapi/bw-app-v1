import '../../api/api_exception.dart';
import '../../api/dio_client.dart';
import '../../models/activity/activity_models.dart';
import '../../services/activity/activity_service.dart';
import '../base_provider.dart';

class ActivityProvider extends BaseProvider<List<ActivityItem>> {
  ActivityProvider({ActivityService? service})
      : _service = service ?? ActivityService(DioClient());

  ActivityService _service;
  List<ActivityCategory> categories = const [
    ActivityCategory(id: 0, title: '全部')
  ];
  int selectedCategoryId = 0;
  ActivityItem? selectedDetail;
  List<ActivityApplyRecord>? activityRecords;
  int recordCurrentPage = 1;
  int recordLastPage = 1;
  bool isRecordsLoading = false;
  bool isRecordsRefreshing = false;
  bool isRecordsLoadingMore = false;
  bool isApplying = false;
  String? recordsError;
  String? applyError;

  List<ActivityItem> get activities => data ?? _fallbackActivities;
  bool get hasRemoteActivities => data != null;
  List<ActivityApplyRecord> get records => activityRecords ?? _fallbackRecords;
  bool get hasRemoteRecords => activityRecords != null;
  bool get hasMoreRecords => recordCurrentPage < recordLastPage;

  void bindClient(DioClient client) {
    _service = ActivityService(client);
  }

  Future<void> loadCategories({bool refresh = false}) async {
    if (isLoading || isRefreshing) return;
    try {
      final remoteCategories = await _service.fetchCategories();
      categories = [
        const ActivityCategory(id: 0, title: '全部'),
        ...remoteCategories.where((item) => item.id > 0),
      ];
      if (!categories.any((item) => item.id == selectedCategoryId)) {
        selectedCategoryId = 0;
      }
      error = null;
      notifyListeners();
    } on ApiException catch (exception) {
      error = exception.message;
      notifyListeners();
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
    }
  }

  Future<void> loadActivities({int? categoryId, bool refresh = false}) async {
    if (isLoading || isRefreshing) return;
    selectedCategoryId = categoryId ?? selectedCategoryId;
    if (refresh) {
      isRefreshing = true;
    } else {
      isLoading = true;
    }
    error = null;
    notifyListeners();

    try {
      data = await _service.fetchActivities(categoryId: selectedCategoryId);
      error = null;
    } on ApiException catch (exception) {
      error = exception.message;
      data ??= _fallbackActivities;
    } catch (exception) {
      error = exception.toString();
      data ??= _fallbackActivities;
    } finally {
      isLoading = false;
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<ActivityItem?> loadActivityDetail(int id) async {
    if (isLoading) return selectedDetail;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      selectedDetail = await _service.fetchActivityDetails(id) ??
          activities.where((item) => item.id == id).firstOrNull;
      error = null;
      return selectedDetail;
    } on ApiException catch (exception) {
      error = exception.message;
      selectedDetail ??= activities.where((item) => item.id == id).firstOrNull;
      return selectedDetail;
    } catch (exception) {
      error = exception.toString();
      selectedDetail ??= activities.where((item) => item.id == id).firstOrNull;
      return selectedDetail;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecords({bool refresh = false}) async {
    if (isRecordsLoading || isRecordsRefreshing) return;
    if (refresh) {
      isRecordsRefreshing = true;
    } else {
      isRecordsLoading = true;
    }
    recordsError = null;
    notifyListeners();

    try {
      final page = await _service.fetchActivityRecords(page: 1);
      activityRecords = page.data;
      recordCurrentPage = page.currentPage;
      recordLastPage = page.lastPage;
      recordsError = null;
    } on ApiException catch (exception) {
      recordsError = exception.message;
      activityRecords ??= _fallbackRecords;
    } catch (exception) {
      recordsError = exception.toString();
      activityRecords ??= _fallbackRecords;
    } finally {
      isRecordsLoading = false;
      isRecordsRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreRecords() async {
    if (isRecordsLoadingMore || isRecordsLoading || !hasMoreRecords) return;
    isRecordsLoadingMore = true;
    recordsError = null;
    notifyListeners();

    try {
      final page = await _service.fetchActivityRecords(
        page: recordCurrentPage + 1,
      );
      activityRecords = [...records, ...page.data];
      recordCurrentPage = page.currentPage;
      recordLastPage = page.lastPage;
    } on ApiException catch (exception) {
      recordsError = exception.message;
    } catch (exception) {
      recordsError = exception.toString();
    } finally {
      isRecordsLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> applyActivity(int id) async {
    if (isApplying || id <= 0) return;
    isApplying = true;
    applyError = null;
    notifyListeners();

    try {
      await _service.applyActivity(id);
      applyError = null;
      activityRecords = null;
      recordCurrentPage = 1;
      recordLastPage = 1;
    } on ApiException catch (exception) {
      applyError = exception.message;
      rethrow;
    } catch (exception) {
      applyError = exception.toString();
      rethrow;
    } finally {
      isApplying = false;
      notifyListeners();
    }
  }
}

const _fallbackActivities = <ActivityItem>[
  ActivityItem(
    id: 1,
    title: '首充送 100%',
    img: 'assets/images/cp.jpg',
    content: '新用户首次充值可获得高达100%返利。',
    type: 1,
    lasting: 1,
  ),
  ActivityItem(
    id: 2,
    title: '周末狂欢',
    img: 'assets/images/dz.jpg',
    content: '周末登录即送免费抽奖机会。',
    type: 1,
    lasting: 1,
  ),
  ActivityItem(
    id: 3,
    title: 'VIP 专属福利',
    img: 'assets/images/zr.jpg',
    content: 'VIP等级越高，返水比例越高。',
    type: 1,
    lasting: 1,
  ),
];

const _fallbackRecords = <ActivityApplyRecord>[
  ActivityApplyRecord(
    username: 'xhdemo',
    status: 1,
    applyTime: '2026-03-24 01:24:58',
    title: 'shoudong',
  ),
];
