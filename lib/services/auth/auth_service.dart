import '../../api/token_storage.dart';
import '../../config/api_endpoints.dart';
import '../../models/auth/auth_models.dart';
import '../base_service.dart';

class AuthService extends BaseService {
  const AuthService(super.client);

  TokenStorage get tokenStorage => client.tokenStorage;

  Future<AuthToken> login(LoginRequest request) {
    return client.post<AuthToken>(
      ApiEndpoints.login,
      data: request.toJson(),
      decoder: AuthToken.fromResponseJson,
    );
  }

  Future<AuthToken> register(RegisterRequest request) {
    return client.post<AuthToken>(
      ApiEndpoints.register,
      data: request.toJson(),
      decoder: AuthToken.fromResponseJson,
    );
  }

  Future<CaptchaData> getCaptcha() {
    return client.post<CaptchaData>(
      ApiEndpoints.captcha,
      decoder: (json) =>
          CaptchaData.fromJson(Map<String, dynamic>.from(json as Map)),
    );
  }

  Future<String> sendEmailCode({required String email, required int type}) {
    return client.post<String>(
      ApiEndpoints.mailCode,
      data: <String, dynamic>{
        'type': type,
        'email': email,
      },
      decoder: _responseMessage,
    );
  }

  Future<String> sendSmsCode({
    required String phone,
    required String areaCode,
    required int type,
  }) {
    return client.post<String>(
      ApiEndpoints.phoneCode,
      data: <String, dynamic>{
        'type': type,
        'area_code': areaCode,
        'phone': phone,
      },
      decoder: _responseMessage,
    );
  }

  String _responseMessage(Object? json) {
    if (json is Map) {
      final message = json['msg'] ?? json['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    }
    return '验证码已发送';
  }

  Future<void> logout() async {
    await client.post<void>(
      ApiEndpoints.logout,
      decoder: (_) {},
    );
  }
}
