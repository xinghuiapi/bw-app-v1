import '../../config/api_endpoints.dart';
import '../../localization/app_language.dart';
import '../../models/activity/activity_models.dart';
import '../base_service.dart';

class ActivityService extends BaseService {
  ActivityService(super.client, {String Function()? currentLanguage})
      : _currentLanguage = currentLanguage;

  final String Function()? _currentLanguage;

  Future<List<ActivityCategory>> fetchCategories() {
    return client.post<List<ActivityCategory>>(
      ApiEndpoints.activityClass,
      decoder: (json) {
        if (json is! List) return const [];
        return json
            .whereType<Map>()
            .map((item) =>
                ActivityCategory.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.title.isNotEmpty)
            .toList();
      },
    );
  }

  Future<List<ActivityItem>> fetchActivities({int? categoryId}) {
    return client.post<List<ActivityItem>>(
      ApiEndpoints.activityList,
      data: categoryId == null || categoryId <= 0 ? null : {'id': categoryId},
      decoder: _activityListFromResponse,
    );
  }

  Future<ActivityItem?> fetchActivityDetails(int id) {
    final language = AppLanguage.normalize(_currentLanguage?.call());
    return client.post<ActivityItem?>(
      ApiEndpoints.activityDetails,
      data: id <= 0 ? null : {'id': id},
      queryParameters: {'lang': language},
      decoder: (json) {
        final list = _activityListFromResponse(json);
        if (id <= 0) return list.firstOrNull;
        return list.where((item) => item.id == id).firstOrNull;
      },
    );
  }

  Future<ActivityRecordPage> fetchActivityRecords({
    int page = 1,
    int size = 10,
  }) {
    return client.post<ActivityRecordPage>(
      ApiEndpoints.activityRecord,
      data: {'page': page, 'size': size},
      decoder: ActivityRecordPage.fromResponse,
    );
  }

  Future<void> applyActivity(int id) {
    return client.post<void>(
      ApiEndpoints.activityApply,
      data: {'id': id},
      decoder: (_) {},
    );
  }

  List<ActivityItem> _activityListFromResponse(dynamic json) {
    if (json is! List) return const [];
    return json
        .whereType<Map>()
        .map((item) => ActivityItem.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.id > 0 && item.title.isNotEmpty)
        .toList();
  }
}
