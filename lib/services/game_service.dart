import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/models/game_model.dart';
import 'package:my_flutter_app/models/betting_models.dart';

class GameService {
  /// 获取投注记录列表
  /// 接口: /api/gamerecord/getlist
  static Future<ApiResponse<BettingRecordsResponse>> getBettingRecords({
    int page = 1,
    int size = 10,
    String? code,
    int? apiCode,
    String? date,
    int? status,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'page': page,
        'size': size,
      };

      if (code != null) data['code'] = code;
      if (apiCode != null) data['api_code'] = apiCode;
      if (date != null) data['date'] = date;
      if (status != null) data['status'] = status;

      final response = await api.post('/gamerecord/getlist', data: data);
      
      return ApiResponse<BettingRecordsResponse>.fromJson(
        response.data,
        (json) => BettingRecordsResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取一级分类列表 (用于投注记录筛选)
  /// 接口: /api/interface/class
  static Future<ApiResponse<List<BettingCategory>>> getPrimaryCategories() async {
    try {
      final response = await api.post('/interface/class');
      
      return ApiResponse<List<BettingCategory>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => BettingCategory.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取二级分类列表 (用于投注记录筛选)
  /// 接口: /api/interface/list
  static Future<ApiResponse<List<BettingCategory>>> getSubCategories(String code) async {
    try {
      final response = await api.post('/interface/list', data: {'code': code});
      
      return ApiResponse<List<BettingCategory>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((item) => BettingCategory.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
  /// 获取子游戏列表
  /// 接口: /api/gamelist/getlist
  static Future<ApiResponse<GameListResponse>> getSubGameList({
    required String gameCode,
    String typeCode = 'game',
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await api.post('/gamelist/getlist', data: {
        'game': gameCode,
        'code': typeCode,
        'page': page,
        'size': size,
      });
      
      return ApiResponse<GameListResponse>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return GameListResponse.fromJson(json);
          }
          return GameListResponse();
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 搜索游戏
  /// 接口: /api/gamelist/getlist (带 title 参数)
  static Future<ApiResponse<GameListResponse>> searchGames({
    required String keyword,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await api.post('/gamelist/getlist', data: {
        'title': keyword,
        'page': page,
        'size': size,
      });
      
      return ApiResponse<GameListResponse>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return GameListResponse.fromJson(json);
          }
          return GameListResponse();
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 游戏登录 (主接口)
  /// 接口: /api/game/login
  static Future<ApiResponse<GameLoginResponse>> gameLogin({
    required dynamic id,
    String lang = 'zh-cn',
  }) async {
    try {
      final response = await api.post(
        '/game/login', 
        data: {'id': id},
        options: dioOptions(headers: {'lang': lang}),
      );
      
      return ApiResponse<GameLoginResponse>.fromJson(
        response.data,
        (json) => GameLoginResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 游戏登录 (备用接口)
  /// 接口: /api/game_code/login
  static Future<ApiResponse<GameLoginResponse>> gameLogin2({ 
    required dynamic id,
    String lang = 'zh-cn',
  }) async {
    try {
      final response = await api.post(
        '/game_code/login', 
        data: {'id': id},
        options: dioOptions(headers: {'lang': lang}),
      );
      
      return ApiResponse<GameLoginResponse>.fromJson(
        response.data,
        (json) => GameLoginResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 一键刷新余额
  /// 接口: /api/game/balance
  static Future<ApiResponse<BalanceResponse>> refreshBalance() async {
    try {
      final response = await api.post('/game/balance');
      
      return ApiResponse<BalanceResponse>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return BalanceResponse.fromJson(json);
          }
          // 如果返回的是直接的余额字符串或其他格式
          if (json is String) {
            return BalanceResponse(balance: json);
          }
          return BalanceResponse();
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
}
