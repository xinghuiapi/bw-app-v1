import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/services/home_service.dart';

/// 滚动到底部通知
class ScrollBottomNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final scrollBottomProvider = NotifierProvider<ScrollBottomNotifier, bool>(ScrollBottomNotifier.new);

/// 首页数据提供
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final response = await HomeService.getSystemConfig();
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  throw Exception(response.msg ?? '加载首页数据失败');
});

/// 游戏分类提供
final categoriesProvider = FutureProvider<List<GameCategory>>((ref) async {
  final response = await HomeService.getGameCategories();
  if (response.isSuccess && response.data != null) {
    return response.data!;
  }
  return [];
});

/// 当前选中的一级分类索引
class SelectedCategoryIndex extends Notifier<int> {
  @override
  int build() => 0;
  void set(int index) => state = index;
}

final selectedCategoryIndexProvider = NotifierProvider<SelectedCategoryIndex, int>(SelectedCategoryIndex.new);

/// 每个一级分类选中的二级分类（独立记忆）
class CategorySelectionNotifier extends Notifier<SubCategory?> {
  @override
  SubCategory? build() => null;
  void set(SubCategory? value) => state = value;
}

final categorySelectionProvider = NotifierProvider.family<CategorySelectionNotifier, SubCategory?, String>((arg) {
  return CategorySelectionNotifier();
});

/// 二级分类提供
final subCategoriesProvider = FutureProvider.family<List<SubCategory>, String>((ref, code) async {
  if (code == 'reco') {
    final response = await HomeService.getRecommendedGames();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return [];
  } else {
    final response = await HomeService.getGameListByCategory(code);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return [];
  }
});
