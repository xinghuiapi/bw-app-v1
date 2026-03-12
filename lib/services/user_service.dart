import 'package:dio/dio.dart';
import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/models/user.dart';
import 'package:my_flutter_app/models/user_models.dart';

class UserService {
  /// 获取VIP等级列表
  /// 接口: /api/vip/getlist
  static Future<ApiResponse<List<VipLevel>>> getVipLevels() async {
    try {
      final response = await api.post('/vip/getlist');
      
      return ApiResponse<List<VipLevel>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => VipLevel.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => VipLevel.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取个人信息
  /// 接口: /api/token/user
  static Future<ApiResponse<User>> getUserInfo() async {
    try {
      final response = await api.post('/token/user');
      
      return ApiResponse<User>.fromJson(
        response.data,
        (json) {
          // 响应数据在 data 数组的第一个元素中，或者直接是 data 对象
          if (json is List && json.isNotEmpty) {
            return User.fromJson(json.first as Map<String, dynamic>);
          }
          if (json is Map<String, dynamic>) {
            // 有时候可能是 { data: [User] } 结构
            if (json.containsKey('data') && json['data'] is List && (json['data'] as List).isNotEmpty) {
              return User.fromJson((json['data'] as List).first as Map<String, dynamic>);
            }
             // 或者直接是对象
            return User.fromJson(json);
          }
          throw Exception('Unexpected user data format');
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 修改个人信息
  /// 接口: /api/user/edit
  static Future<ApiResponse<void>> updateUserProfile(UserProfileUpdateRequest request) async {
    try {
      final response = await api.post('/user/edit', data: request.toJson());
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 收藏/取消收藏游戏
  /// 接口: /api/user_favorites/game
  /// params: { "id": int, "status": int } (status: 1 收藏, 0 取消收藏)
  static Future<ApiResponse<void>> toggleGameFavorite(int gameId, int status) async {
    try {
      final response = await api.post('/user_favorites/game', data: {
        'id': gameId,
        'status': status,
      });
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 上传图片
  /// 接口: /api/img/save
  static Future<ApiResponse<Map<String, dynamic>>> uploadImage(List<int> bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
        'name': 'avatar',
      });

      final response = await api.post(
        '/img/save',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return ApiResponse<Map<String, dynamic>>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
        data: response.data['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 设置/更新支付密码
  /// 接口: /api/user/pay_password
  static Future<ApiResponse<void>> setPayPassword(String payPassword, {String? oldPayPassword}) async {
    try {
      final data = {
        'pay_password': payPassword,
      };
      if (oldPayPassword != null) {
        data['old_pay_password'] = oldPayPassword;
      }
      final response = await api.post('/user/pay_password', data: data);
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取返水信息
  /// 接口: /api/user/rebate_info
  static Future<ApiResponse<UserRebateInfo>> getRebateInfo() async {
    try {
      final response = await api.post('/user/rebate_info');
      return ApiResponse<UserRebateInfo>.fromJson(
        response.data,
        (json) => UserRebateInfo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 领取返水
  /// 接口: /api/user/claim_rebate
  static Future<ApiResponse<void>> claimRebate() async {
    try {
      final response = await api.post('/user/claim_rebate');
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取用户消息列表
  /// 接口: /api/notify/getlist
  static Future<ApiResponse<List<UserMessage>>> getUserMessages({int page = 1, int size = 20}) async {
    try {
      final response = await api.post('/notify/getlist', data: {'page': page, 'size': size});
      
      return ApiResponse<List<UserMessage>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => UserMessage.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (json is List) {
            return json.map((e) => UserMessage.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 标记消息为已读
  /// 接口: /api/notify/status
  static Future<ApiResponse<void>> markMessageAsRead(int messageId) async {
    try {
      final response = await api.post('/notify/status', data: {'id': messageId});
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 标记所有消息为已读
  /// 接口: /api/notify/all
  static Future<ApiResponse<void>> markAllMessagesAsRead() async {
    try {
      final response = await api.post('/notify/all');
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取用户设置
  /// 接口: /api/user/settings
  static Future<ApiResponse<Map<String, dynamic>>> getUserSettings() async {
    try {
      final response = await api.post('/user/settings');
      return ApiResponse<Map<String, dynamic>>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
        data: response.data['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
}
