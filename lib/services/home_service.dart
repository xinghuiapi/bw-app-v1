import 'dart:convert';
import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/models/home_data.dart';

class HomeService {
  /// 获取系统配置
  /// 接口: /api/system/getlist
  static Future<ApiResponse<HomeData>> getSystemConfig() async {
    try {
      final response = await api.post('/system/getlist');

      return ApiResponse<HomeData>.fromJson(response.data, (json) {
        // 响应数据在 data.data 字段中
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          final innerData = json['data'];
          if (innerData is Map<String, dynamic> && innerData.containsKey('data')) {
            return HomeData.fromJson(innerData['data'] as Map<String, dynamic>);
          }
          return HomeData.fromJson(innerData as Map<String, dynamic>);
        }
        return HomeData.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取推荐游戏
  /// 接口: /api/interface/reco
  static Future<ApiResponse<List<SubCategory>>> getRecommendedGames() async {
    try {
      final response = await api.post('/interface/reco');

      return ApiResponse<List<SubCategory>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取首页数据
  /// 接口: /api/home
  static Future<ApiResponse<HomeData>> getHomeData() async {
    try {
      final response = await api.get('/home');

      return ApiResponse<HomeData>.fromJson(response.data, (json) {
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return HomeData.fromJson(json['data'] as Map<String, dynamic>);
        }
        return HomeData.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取游戏分类
  /// 接口: /api/interface/class
  static Future<ApiResponse<List<GameCategory>>> getGameCategories() async {
    try {
      final response = await api.post('/interface/class');

      return ApiResponse<List<GameCategory>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => GameCategory.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取分类下的游戏列表
  /// 接口: /api/interface/list
  /// 参数: code (分类标识，如 live)
  static Future<ApiResponse<List<SubCategory>>> getGameListByCategory(
    String code,
  ) async {
    try {
      final response = await api.post('/interface/list', data: {'code': code});

      return ApiResponse<List<SubCategory>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取活动分类
  /// 接口: /api/activity/class
  static Future<ApiResponse<List<ActivityClass>>> getActivityClass() async {
    try {
      final response = await api.post('/activity/class');

      return ApiResponse<List<ActivityClass>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => ActivityClass.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取活动列表
  /// 接口: /api/activity/list
  static Future<ApiResponse<List<Activity>>> getActivityList(int? id) async {
    try {
      final data = id != null ? {'id': id} : {};
      final response = await api.post('/activity/list', data: data);

      return ApiResponse<List<Activity>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (json is Map<String, dynamic> &&
            json.containsKey('data') &&
            json['data'] is List) {
          return (json['data'] as List)
              .map((e) => Activity.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取活动详情
  /// 接口: /api/activity/details
  static Future<ApiResponse<Activity>> getActivityDetails(int id) async {
    try {
      final response = await api.post('/activity/details', data: {'id': id});
      
      dynamic responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      return ApiResponse<Activity>.fromJson(responseData, (json) {
        if (json is List && json.isNotEmpty) {
          return Activity.fromJson(Map<String, dynamic>.from(json.first as Map));
        }
        if (json is Map) {
          if (json.containsKey('data')) {
            return Activity.fromJson(Map<String, dynamic>.from(json['data'] as Map));
          }
          return Activity.fromJson(Map<String, dynamic>.from(json));
        }
        return Activity();
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 申请活动
  /// 接口: /api/activity/apply
  static Future<ApiResponse<void>> applyActivity(int id) async {
    try {
      final response = await api.post('/activity/apply', data: {'id': id});
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取反馈分类列表
  /// 接口: /api/feedback_type/getlist
  static Future<ApiResponse<List<FeedbackType>>> getFeedbackTypes({
    String lang = 'CN',
  }) async {
    try {
      final response = await api.post(
        '/feedback_type/getlist',
        options: dioOptions(headers: {'lang': lang}),
      );

      return ApiResponse<List<FeedbackType>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => FeedbackType.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (json is Map && json.containsKey('data')) {
          final dataList = json['data'];
          if (dataList is List) {
            return dataList
                .map((e) => FeedbackType.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 提交问题反馈
  /// 接口: /api/feedback/to
  static Future<ApiResponse<void>> submitFeedback(
    int id,
    String text, {
    String? img,
    String lang = 'CN',
  }) async {
    try {
      final data = {'id': id, 'text': text, 'img': img}
        ..removeWhere((key, value) => value == null);
      final response = await api.post(
        '/feedback/to',
        data: data,
        options: dioOptions(headers: {'lang': lang}),
      );
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 上传图片文件
  /// 接口: /api/img/save
  static Future<ApiResponse<String>> uploadImage(
    dynamic formData, {
    String lang = 'CN',
  }) async {
    try {
      final response = await api.post(
        '/img/save',
        data: formData,
        options: dioOptions(
          headers: {'Content-Type': 'multipart/form-data', 'lang': lang},
        ),
      );

      return ApiResponse<String>.fromJson(response.data, (json) {
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return json['data'] as String;
        }
        return json.toString();
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取单页分类列表
  /// 接口: /api/single/class
  static Future<ApiResponse<List<SinglePageClass>>> getSingleClass() async {
    try {
      final response = await api.post('/single/class');

      return ApiResponse<List<SinglePageClass>>.fromJson(response.data, (json) {
        if (json is List) {
          return json
              .map((e) => SinglePageClass.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取单页内容
  /// 接口: /api/single/getlist
  static Future<ApiResponse<SinglePageContent>> getSingleContent(int id) async {
    try {
      final response = await api.post('/single/getlist', data: {'id': id});

      return ApiResponse<SinglePageContent>.fromJson(response.data, (json) {
        if (json is Map<String, dynamic> && json.containsKey('data')) {
          return SinglePageContent.fromJson(
            json['data'] as Map<String, dynamic>,
          );
        }
        return SinglePageContent.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
}
