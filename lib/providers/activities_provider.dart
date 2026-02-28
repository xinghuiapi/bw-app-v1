import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_data.dart';
import '../services/home_service.dart';

/// 活动分类提供者
final activityCategoriesProvider = FutureProvider<List<ActivityClass>>((ref) async {
  final response = await HomeService.getActivityClass();
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  return [];
});

/// 当前选中的活动分类 ID
class SelectedActivityCategoryId extends Notifier<int?> {
  @override
  int? build() => null;
  void set(int? id) => state = id;
}
final selectedActivityCategoryIdProvider = NotifierProvider<SelectedActivityCategoryId, int?>(SelectedActivityCategoryId.new);

/// 活动列表提供者
final activityListProvider = FutureProvider.family<List<Activity>, int?>((ref, categoryId) async {
  final response = await HomeService.getActivityList(categoryId);
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  return [];
});

/// 活动详情提供者
final activityDetailProvider = FutureProvider.family<Activity, int>((ref, id) async {
  final response = await HomeService.getActivityDetails(id);
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  throw Exception(response.msg ?? '获取活动详情失败');
});
