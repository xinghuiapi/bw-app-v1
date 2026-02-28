import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../models/home_data.dart';
import '../models/api_response.dart';
import 'language_provider.dart';

/// 首页数据提供者
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final lang = ref.watch(languageProvider);
  try {
    // 并行获取全局配置和分类数据 (对标 Vue 中的 initHomeData)
    final results = await Future.wait([
      api.post('/system/getlist', options: dioOptions(headers: {'lang': lang})),
      api.post('/interface/class', options: dioOptions(headers: {'lang': lang})),
    ]);

    final configResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      results[0].data,
      (json) => json as Map<String, dynamic>,
    );

    if (configResponse.isSuccess) {
      // 提取 data.data 中的配置
      // 部分接口直接返回配置在 data 中，部分在 data.data 中
      // 优先尝试读取 data.data，如果不存在或为 null，则直接使用 data
      final configData = configResponse.data?['data'] ?? configResponse.data;
      
      if (configData != null) {
        return HomeData.fromJson(configData);
      }
    }
    throw Exception(configResponse.msg ?? '加载首页数据失败');
  } catch (e) {
      // 这里的 print 仅用于开发调试，后续会接入统一的日志系统
      // ignore: avoid_print
      print('Error loading home data: $e');
      rethrow;
    }
});

/// 游戏分类提供者
final categoriesProvider = FutureProvider<List<GameCategory>>((ref) async {
  final lang = ref.watch(languageProvider);
  final response = await api.post('/interface/class', options: dioOptions(headers: {'lang': lang}));
  final apiResponse = ApiResponse<List<dynamic>>.fromJson(
    response.data,
    (json) => json as List<dynamic>,
  );

  if (apiResponse.isSuccess && apiResponse.data != null) {
    return apiResponse.data!
        .map((e) => GameCategory.fromJson(e as Map<String, dynamic>))
        .toList();
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

/// 当前选中的二级分类索引
class SelectedSubCategoryIndex extends Notifier<int> {
  @override
  int build() => 0;
  void set(int index) => state = index;
}
final selectedSubCategoryIndexProvider = NotifierProvider<SelectedSubCategoryIndex, int>(SelectedSubCategoryIndex.new);

/// 二级分类提供者
final subCategoriesProvider = FutureProvider.family<List<SubCategory>, String>((ref, code) async {
  final lang = ref.watch(languageProvider);
  try {
    if (code == 'reco') {
      final response = await api.post('/interface/reco', options: dioOptions(headers: {'lang': lang}));
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );
      if (apiResponse.isSuccess && apiResponse.data != null) {
        return apiResponse.data!.map((item) {
          final map = item as Map<String, dynamic>;
          // 推荐数据结构映射为 SubCategory
          return SubCategory(
            id: map['id'],
            title: map['title'],
            h5Logo: map['img'],
            pcLogo: map['img'],
            gamecode: map['gamecode'],
            category: 0,
            statusS: 1,
            img: map['img'],
            label: map['label'],
          );
        }).toList();
      }
    } else {
      final response = await api.post('/interface/list', data: {'code': code}, options: dioOptions(headers: {'lang': lang}));
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );
      if (apiResponse.isSuccess && apiResponse.data != null) {
        return apiResponse.data!
            .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  } catch (e) {
    // ignore: avoid_print
    print('Error loading sub-categories for $code: $e');
    rethrow;
  }
});

/// 游戏列表请求参数
class GameListParams {
  final String game;
  final String code;
  final int page;
  final int size;
  final String searchWord;

  GameListParams({
    required this.game,
    required this.code,
    this.page = 1,
    this.size = 20,
    this.searchWord = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameListParams &&
          runtimeType == other.runtimeType &&
          game == other.game &&
          code == other.code &&
          page == other.page &&
          size == other.size &&
          searchWord == other.searchWord;

  @override
  int get hashCode =>
      game.hashCode ^
      code.hashCode ^
      page.hashCode ^
      size.hashCode ^
      searchWord.hashCode;
}

/// 游戏列表提供者
final gameListProvider = FutureProvider.family<List<GameItem>, GameListParams>((ref, params) async {
  final lang = ref.watch(languageProvider);
  try {
    final response = await api.post('/gamelist/getlist', data: {
      'page': params.page,
      'size': params.size,
      'game': params.game,
      'code': params.code,
      'search_word': params.searchWord,
    }, options: dioOptions(headers: {'lang': lang}));

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (apiResponse.isSuccess && apiResponse.data != null) {
      final gamesData = apiResponse.data!['data'] as List<dynamic>?;
      if (gamesData != null) {
        return gamesData.map((e) => GameItem.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    return [];
  } catch (e) {
      // ignore: avoid_print
      print('Error fetching game list: $e');
      return [];
    }
});
