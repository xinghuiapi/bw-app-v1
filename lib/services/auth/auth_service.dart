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

  Future<VerificationCodeData> sendEmailCode({
    required String email,
    required int type,
    String? username,
  }) {
    return client.post<VerificationCodeData>(
      ApiEndpoints.mailCode,
      data: <String, dynamic>{
        'type': type,
        'email': email,
        if (username != null && username.trim().isNotEmpty)
          'username': username.trim(),
      },
      decoder: _verificationCodeData,
    );
  }

  Future<VerificationCodeData> sendSmsCode({
    required String phone,
    required String areaCode,
    required int type,
  }) {
    return client.post<VerificationCodeData>(
      ApiEndpoints.phoneCode,
      data: <String, dynamic>{
        'type': type,
        'area_code': areaCode,
        'phone': phone,
      },
      decoder: _verificationCodeData,
    );
  }

  Future<VerificationCodeData> sendResetPasswordCode({
    required int type,
    String? areaCode,
    String? phone,
    String? email,
  }) {
    return client.post<VerificationCodeData>(
      ApiEndpoints.smsCode,
      data: <String, dynamic>{
        'type': type,
        if (areaCode != null && areaCode.trim().isNotEmpty)
          'area_code': areaCode.trim(),
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      },
      decoder: _verificationCodeData,
    );
  }

  Future<void> resetPassword(ResetPasswordRequest request) {
    return client.post<void>(
      ApiEndpoints.resetPassword,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  Future<AuthToken> telegramLogin(TelegramLoginRequest request) {
    return client.post<AuthToken>(
      ApiEndpoints.telegramLogin,
      data: request.toJson(),
      decoder: AuthToken.fromResponseJson,
    );
  }

  Future<void> setTelegramPassword(SetTelegramPasswordRequest request) {
    return client.post<void>(
      ApiEndpoints.telegramPassword,
      data: request.toJson(),
      decoder: (_) {},
    );
  }

  VerificationCodeData _verificationCodeData(Object? json) {
    if (json is Map) {
      return VerificationCodeData.fromJson(Map<String, dynamic>.from(json));
    }
    return const VerificationCodeData();
  }

  Future<void> logout() async {
    await client.post<void>(
      ApiEndpoints.logout,
      decoder: (_) {},
    );
  }
}
