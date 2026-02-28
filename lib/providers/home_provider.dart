import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../api/dio_client.dart';
import '../models/home_data.dart';
import '../models/api_response.dart';
import 'language_provider.dart';

/// 滚动到底部通知
class ScrollBottomNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
final scrollBottomProvider = NotifierProvider<ScrollBottomNotifier, bool>(ScrollBottomNotifier.new);

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
  print('Loading categories...');
  try {
    final lang = ref.watch(languageProvider);
    final response = await api.post('/interface/class', options: dioOptions(headers: {'lang': lang}));
    final apiResponse = ApiResponse<List<dynamic>>.fromJson(
      response.data,
      (json) => json as List<dynamic>,
    );
    if (apiResponse.isSuccess && apiResponse.data != null) {
      final categories = apiResponse.data!
          .map((e) => GameCategory.fromJson(e as Map<String, dynamic>))
          .toList();
      print('Categories loaded: ${categories.length}');
      return categories;
    }
    print('Failed to load categories: ${apiResponse.msg}');
    return [];
  } catch (e) {
    print('Error loading categories: $e');
    rethrow;
  }
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

/// 游戏列表分页状态
class GameListPaginationState {
  final List<GameItem> items;
  final int currentPage;
  final int lastPage;
  final bool isLoading;
  final String? error;

  GameListPaginationState({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.isLoading,
    this.error,
  });

  bool get hasMore => currentPage < lastPage;

  GameListPaginationState copyWith({
    List<GameItem>? items,
    int? currentPage,
    int? lastPage,
    bool? isLoading,
    String? error,
  }) {
    return GameListPaginationState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 游戏列表参数类
class GameListParams {
  final dynamic game;
  final String? code;
  final int size;
  final String? searchWord;

  GameListParams({
    this.game,
    this.code,
    this.size = 20,
    this.searchWord,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameListParams &&
          runtimeType == other.runtimeType &&
          game == other.game &&
          code == other.code &&
          size == other.size &&
          searchWord == other.searchWord;

  @override
  int get hashCode => game.hashCode ^ code.hashCode ^ size.hashCode ^ searchWord.hashCode;
}

/// 游戏列表提供者 (使用 StateNotifierProvider.family 处理分页逻辑)
class GameListNotifier extends StateNotifier<GameListPaginationState> {
  final Ref ref;
  final GameListParams arg;

  GameListNotifier(this.ref, this.arg)
      : super(GameListPaginationState(
          items: [],
          currentPage: 0,
          lastPage: 1,
          isLoading: false,
        )) {
    // 初始加载
    loadMore();
  }

  Future<void> loadMore() async {
    final currentState = state;
    print('loadMore called: page=${currentState.currentPage + 1}, arg.game=${arg.game}, arg.code=${arg.code}');
    
    // 如果正在加载，或者已经加载完所有页面，则直接返回
    if (currentState.isLoading || (currentState.currentPage >= currentState.lastPage && currentState.currentPage != 0)) return;
    
    state = currentState.copyWith(isLoading: true, error: null);
    
    try {
      final nextPage = currentState.currentPage + 1;
      final lang = ref.read(languageProvider);
      
      final response = await api.post('/gamelist/getlist', data: {
        'page': nextPage,
        'size': arg.size,
        'game': arg.game,
        'code': arg.code,
        'title': arg.searchWord,
      }, options: dioOptions(headers: {'lang': lang}));

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        final dynamic data = apiResponse.data;
        List<GameItem> newItems = [];
        int lastPage = currentState.lastPage;
        int currentPage = nextPage;
        
        if (data is Map<String, dynamic>) {
          final dynamic gamesData = data['data'];
          if (gamesData is List) {
            newItems = gamesData.map((e) => GameItem.fromJson(e as Map<String, dynamic>)).toList();
          } else if (gamesData is Map) {
            newItems = gamesData.values.map((e) => GameItem.fromJson(e as Map<String, dynamic>)).toList();
          }
          lastPage = int.tryParse(data['lastPage']?.toString() ?? '') ?? lastPage;
          currentPage = int.tryParse(data['current_page']?.toString() ?? '') ?? currentPage;
        } else if (data is List) {
          newItems = data.map((e) => GameItem.fromJson(e as Map<String, dynamic>)).toList();
          lastPage = 1; // 如果是列表，认为只有一页
        }
        
        state = currentState.copyWith(
          items: nextPage == 1 ? newItems : [...currentState.items, ...newItems],
          currentPage: currentPage,
          lastPage: lastPage,
          isLoading: false,
        );
      } else {
        state = currentState.copyWith(
          isLoading: false, 
          error: apiResponse.msg ?? '加载失败'
        );
      }
    } catch (e) {
      state = currentState.copyWith(
        isLoading: false, 
        error: e.toString()
      );
    }
  }
}

final gameListProvider = StateNotifierProvider.family<GameListNotifier, GameListPaginationState, GameListParams>((ref, arg) {
  return GameListNotifier(ref, arg);
});
