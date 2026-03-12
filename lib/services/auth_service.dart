import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/api_response.dart';
import 'package:my_flutter_app/models/auth_models.dart';

class AuthService {
  static Future<ApiResponse<AuthResponseData>> login(LoginRequest request) async {
    try {
      final response = await api.post('/user/login', data: request.toJson());
      
      return ApiResponse<AuthResponseData>.fromJson(
        response.data,
        (json) {
          // 根据响应示例，数据在 data 字段中
          if (json is Map<String, dynamic> && json.containsKey('access_token')) {
            return AuthResponseData.fromJson(json);
          }
          // 如果响应结构是 { code: 200, data: { ... } }
          final map = json as Map<String, dynamic>;
          if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
            return AuthResponseData.fromJson(map['data'] as Map<String, dynamic>);
          }
          return AuthResponseData.fromJson(map);
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<AuthResponseData>> register(RegisterRequest request) async {
    try {
      final response = await api.post('/user/register', data: request.toJson());
      
      return ApiResponse<AuthResponseData>.fromJson(
        response.data,
        (json) {
          final map = json as Map<String, dynamic>;
          if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
            return AuthResponseData.fromJson(map['data'] as Map<String, dynamic>);
          }
          return AuthResponseData.fromJson(map);
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> logout() async {
    try {
      // ⚠️ 对标原项目接口/token/logout
      final response = await api.post('/token/logout');
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<CaptchaData>> getCaptcha() async {
    try {
      final response = await api.post('/captcha/get');
      
      return ApiResponse<CaptchaData>.fromJson(
        response.data,
        (json) {
          final map = json as Map<String, dynamic>;
          // 验证码数据通常也在 data 字段中
          if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
            return CaptchaData.fromJson(map['data'] as Map<String, dynamic>);
          }
          return CaptchaData.fromJson(map);
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> sendEmailCode(String email, {String? username, int type = 2}) async {
    try {
      final response = await api.post('/mail_code/send', data: {
        'email': email,
        'username': username ?? '',
        'type': type,
      });
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> sendSmsCode(String phone, String areaCode, {int type = 2}) async {
    try {
      final response = await api.post('/phone_code/send', data: {
        'phone': phone,
        'area_code': areaCode,
        'type': type,
      });
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<AuthResponseData>> telegramLogin(TelegramLoginRequest request) async {
    try {
      final response = await api.post('/telegram/login', data: request.toJson());
      
      return ApiResponse<AuthResponseData>.fromJson(
        response.data,
        (json) {
          final map = json as Map<String, dynamic>;
          if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
            return AuthResponseData.fromJson(map['data'] as Map<String, dynamic>);
          }
          return AuthResponseData.fromJson(map);
        },
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> setTelegramPassword(SetTelegramPasswordRequest request) async {
    try {
      final response = await api.post('/telegram/password', data: request.toJson());
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> sendResetPasswordCode({
    required int type, // 1手机验证码，2邮箱验证码
    String? areaCode,
    String? phone,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'type': type,
      };
      if (phone != null || areaCode != null || email != null) {
        if (areaCode != null) data['area_code'] = areaCode;
        if (phone != null) data['phone'] = phone;
        if (email != null) data['email'] = email;
      }
      final response = await api.post('/code/send', data: data);
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> resetPassword({
    required int type, // 1手机号验证码找回，2邮箱验证码找回，3真实姓名+安全密码找回
    String? areaCode,
    String? phone,
    String? email,
    String? realName,
    String? payPassword,
    String? code,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'type': type,
        'password': password,
      };
      if (type == 1) {
        data['area_code'] = areaCode ?? '86';
        data['phone'] = phone ?? '';
        data['code'] = code ?? '';
      } else if (type == 2) {
        data['email'] = email ?? '';
        data['code'] = code ?? '';
      } else if (type == 3) {
        data['real_name'] = realName ?? '';
        data['pay_password'] = payPassword ?? '';
      }
      final response = await api.post('/password/get', data: data);
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }
}
