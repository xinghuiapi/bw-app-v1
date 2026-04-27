import 'package:my_flutter_app/api/dio_client.dart';
import 'package:my_flutter_app/models/core/api_response.dart';
import 'package:my_flutter_app/models/auth/auth_models.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';

class AuthService {
  static Future<ApiResponse<AuthResponseData>> login(
    LoginRequest request,
  ) async {
    try {
      final response = await api.post('/user/login', data: request.toJson());
      final Map<String, dynamic> responseData = response.data;

      // 统一解析逻辑：尝试从 root 或 data 字段提取 token 信息
      final dynamic dataField = responseData['data'];
      Map<String, dynamic> combinedData = {};

      if (dataField is Map<String, dynamic>) {
        combinedData.addAll(dataField);
      }
      
      // 如果 root 层有这些字段，覆盖 data 层（对标原项目逻辑）
      if (responseData.containsKey('access_token')) combinedData['access_token'] = responseData['access_token'];
      if (responseData.containsKey('refresh_token')) combinedData['refresh_token'] = responseData['refresh_token'];
      if (responseData.containsKey('expires_in')) combinedData['expires_in'] = responseData['expires_in'];
      if (responseData.containsKey('token_type')) combinedData['token_type'] = responseData['token_type'];

      // 如果找到了 access_token，则认为解析成功
      if (combinedData.containsKey('access_token')) {
        return ApiResponse<AuthResponseData>(
          code: responseData['code'] ?? 200,
          msg: responseData['msg'] ?? 'success',
          data: AuthResponseData.fromJson(combinedData),
        );
      }

      // 降级处理
      return ApiResponse<AuthResponseData>.fromJson(responseData, (json) {
        return AuthResponseData.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<AuthResponseData>> register(
    RegisterRequest request,
  ) async {
    try {
      final response = await api.post('/user/register', data: request.toJson());
      final Map<String, dynamic> responseData = response.data;

      final dynamic dataField = responseData['data'];
      Map<String, dynamic> combinedData = {};

      if (dataField is Map<String, dynamic>) {
        combinedData.addAll(dataField);
      }
      
      if (responseData.containsKey('access_token')) combinedData['access_token'] = responseData['access_token'];
      if (responseData.containsKey('refresh_token')) combinedData['refresh_token'] = responseData['refresh_token'];
      if (responseData.containsKey('expires_in')) combinedData['expires_in'] = responseData['expires_in'];

      if (combinedData.containsKey('access_token')) {
        return ApiResponse<AuthResponseData>(
          code: responseData['code'] ?? 200,
          msg: responseData['msg'] ?? 'success',
          data: AuthResponseData.fromJson(combinedData),
        );
      }

      return ApiResponse<AuthResponseData>.fromJson(responseData, (json) {
        return AuthResponseData.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<AuthResponseData>> refreshToken() async {
    try {
      final refreshToken = await AuthHelper.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return ApiResponse(code: -1, msg: 'No refresh token available');
      }
      final response = await api.post(
        '/token/refresh',
        data: {'refresh_token': refreshToken},
      );
      return ApiResponse<AuthResponseData>.fromJson(response.data, (json) {
        final map = json as Map<String, dynamic>;
        if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
          return AuthResponseData.fromJson(map['data'] as Map<String, dynamic>);
        }
        return AuthResponseData.fromJson(map);
      });
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

      return ApiResponse<CaptchaData>.fromJson(response.data, (json) {
        final map = json as Map<String, dynamic>;
        // 验证码数据通常也在 data 字段中
        if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
          return CaptchaData.fromJson(map['data'] as Map<String, dynamic>);
        }
        return CaptchaData.fromJson(map);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> sendEmailCode(
    String email, {
    String? username,
    int type = 2,
  }) async {
    try {
      final response = await api.post(
        '/mail_code/send',
        data: {'email': email, 'username': username ?? '', 'type': type},
      );
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> sendSmsCode(
    String phone,
    String areaCode, {
    int type = 2,
  }) async {
    try {
      final response = await api.post(
        '/phone_code/send',
        data: {'phone': phone, 'area_code': areaCode, 'type': type},
      );
      return ApiResponse<void>(
        code: response.data['code'] ?? -1,
        msg: response.data['msg'],
      );
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<AuthResponseData>> telegramLogin(
    TelegramLoginRequest request,
  ) async {
    try {
      final response = await api.post(
        '/telegram/login',
        data: request.toJson(),
      );
      final Map<String, dynamic> responseData = response.data;

      final dynamic dataField = responseData['data'];
      Map<String, dynamic> combinedData = {};

      if (dataField is Map<String, dynamic>) {
        combinedData.addAll(dataField);
      }
      
      if (responseData.containsKey('access_token')) combinedData['access_token'] = responseData['access_token'];
      if (responseData.containsKey('refresh_token')) combinedData['refresh_token'] = responseData['refresh_token'];
      if (responseData.containsKey('expires_in')) combinedData['expires_in'] = responseData['expires_in'];

      if (combinedData.containsKey('access_token')) {
        return ApiResponse<AuthResponseData>(
          code: responseData['code'] ?? 200,
          msg: responseData['msg'] ?? 'success',
          data: AuthResponseData.fromJson(combinedData),
        );
      }

      return ApiResponse<AuthResponseData>.fromJson(responseData, (json) {
        return AuthResponseData.fromJson(json as Map<String, dynamic>);
      });
    } catch (e) {
      return ApiResponse(code: -1, msg: e.toString());
    }
  }

  static Future<ApiResponse<void>> setTelegramPassword(
    SetTelegramPasswordRequest request,
  ) async {
    try {
      final response = await api.post(
        '/telegram/password',
        data: request.toJson(),
      );
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
      final Map<String, dynamic> data = {'type': type};
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
      final Map<String, dynamic> data = {'type': type, 'password': password};
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
