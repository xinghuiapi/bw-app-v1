import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/user_models.dart';

class UserService {
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
      return ApiResponse<void>.fromJson(response.data, (_) {});
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

      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
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
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取用户消息列表
  /// 接口: /api/user/messages
  static Future<ApiResponse<List<UserMessage>>> getUserMessages({int page = 1, int limit = 20}) async {
    try {
      // 注意：这里 user.js 使用的是 GET 请求
      final response = await api.get('/user/messages', queryParameters: {'page': page, 'limit': limit});
      
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
  /// 接口: /api/user/messages/{id}/read
  static Future<ApiResponse<void>> markMessageAsRead(int messageId) async {
    try {
      final response = await api.post('/user/messages/$messageId/read');
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 删除消息
  /// 接口: /api/user/messages/{id}
  static Future<ApiResponse<void>> deleteMessage(int messageId) async {
    try {
      final response = await api.delete('/user/messages/$messageId');
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取用户设置
  /// 接口: /api/user/settings
  static Future<ApiResponse<Map<String, dynamic>>> getUserSettings() async {
    try {
      final response = await api.get('/user/settings');
      
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return json;
          }
          return {};
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 更新用户设置
  /// 接口: /api/user/settings
  static Future<ApiResponse<void>> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final response = await api.post('/user/settings', data: settings);
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取用户安全设置
  /// 接口: /api/user/security-settings
  static Future<ApiResponse<Map<String, dynamic>>> getUserSecuritySettings() async {
    try {
      final response = await api.get('/user/security-settings');
      
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic>) {
            return json;
          }
          return {};
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 更新用户安全设置
  /// 接口: /api/user/security-settings
  static Future<ApiResponse<void>> updateUserSecuritySettings(Map<String, dynamic> settings) async {
    try {
      final response = await api.post('/user/security-settings', data: settings);
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
  
  /// 获取用户VIP信息
  /// 接口: /api/user/vip
  static Future<ApiResponse<Map<String, dynamic>>> getUserVipInfo() async {
    try {
      final response = await api.get('/user/vip');
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
  
  /// 获取用户钱包信息
  /// 接口: /api/user/wallet
  static Future<ApiResponse<Map<String, dynamic>>> getUserWallet() async {
    try {
      final response = await api.get('/user/wallet');
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
  
  /// 获取用户代理信息
  /// 接口: /api/user/agent
  static Future<ApiResponse<Map<String, dynamic>>> getUserAgentInfo() async {
    try {
      final response = await api.get('/user/agent');
      return ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取返利数据
  /// 接口: /api/retabe/list
  static Future<ApiResponse<UserRebateInfo>> getRebateInfo() async {
    try {
      final response = await api.post('/retabe/list');
      return ApiResponse<UserRebateInfo>.fromJson(
        response.data,
        (json) => UserRebateInfo.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 领取返利
  /// 接口: /api/retabe/amount
  static Future<ApiResponse<void>> claimRebate() async {
    try {
      final response = await api.post('/retabe/amount');
      return ApiResponse<void>.fromJson(response.data, (_) {});
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  /// 获取VIP等级列表
  /// 接口: /api/vip/getlist
  static Future<ApiResponse<List<VipLevel>>> getVipLevels() async {
    try {
      final response = await api.post('/vip/getlist');
      return ApiResponse<List<VipLevel>>.fromJson(
        response.data,
        (json) {
          if (json is Map<String, dynamic> && json.containsKey('data') && json['data'] is List) {
            return (json['data'] as List).map((e) => VipLevel.fromJson(e as Map<String, dynamic>)).toList();
          }
          if (json is List) {
            return json.map((e) => VipLevel.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
}
