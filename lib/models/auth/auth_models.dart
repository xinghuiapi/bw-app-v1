import '../core/json_utils.dart';

class LoginRequest {
  final int type;
  final String? username;
  final String? password;
  final String? email;
  final String? emailCode;
  final String? phone;
  final String? areaCode;
  final String? phoneCode;
  final String? captchaCode;
  final String? captchaKey;

  const LoginRequest({
    required this.type,
    this.username,
    this.password,
    this.email,
    this.emailCode,
    this.phone,
    this.areaCode,
    this.phoneCode,
    this.captchaCode,
    this.captchaKey,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (_hasValue(username)) 'username': username!.trim(),
        if (_hasValue(password)) 'password': password!.trim(),
        if (_hasValue(email)) 'email': email!.trim(),
        if (_hasValue(emailCode)) 'email_code': emailCode!.trim(),
        if (_hasValue(phone)) 'phone': phone!.trim(),
        if (_hasValue(areaCode)) 'area_code': areaCode!.trim(),
        if (_hasValue(phoneCode)) 'phone_code': phoneCode!.trim(),
        if (_hasValue(captchaCode)) 'captcha_code': captchaCode!.trim(),
        if (_hasValue(captchaKey)) 'captcha_key': captchaKey!.trim(),
      };
}

class RegisterRequest {
  final String username;
  final String password;
  final String confirmPassword;
  final String? currency;
  final String? phone;
  final String? areaCode;
  final String? phoneCode;
  final String? email;
  final String? name;
  final Object? qq;
  final String? telegram;
  final String? captchaCode;
  final String? captchaKey;
  final String? emailCode;
  final String? inviteCode;
  final String? payPassword;

  const RegisterRequest({
    required this.username,
    required this.password,
    required this.confirmPassword,
    this.currency,
    this.phone,
    this.areaCode,
    this.phoneCode,
    this.email,
    this.name,
    this.qq,
    this.telegram,
    this.captchaCode,
    this.captchaKey,
    this.emailCode,
    this.inviteCode,
    this.payPassword,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'o_password': confirmPassword,
        'currency': _orEmpty(currency),
        'phone': _orEmpty(phone),
        'area_code': _orEmpty(areaCode),
        'phone_code': _orEmpty(phoneCode),
        'email': _orEmpty(email),
        'name': _orEmpty(name),
        'qq': qq ?? 0,
        'telegram': _orEmpty(telegram),
        'captcha_code': _orEmpty(captchaCode),
        'captcha_key': _orEmpty(captchaKey),
        'email_code': _orEmpty(emailCode),
        'invicode': _orEmpty(inviteCode),
        'pay_password': _orEmpty(payPassword),
      };
}

class AuthToken {
  final String accessToken;
  final String? rawToken;
  final String? tokenType;
  final int? expiresIn;
  final String? refreshToken;
  final bool? oneLogin;
  final bool? isOneLogin;
  final Map<String, dynamic> raw;

  const AuthToken({
    required this.accessToken,
    this.rawToken,
    this.tokenType,
    this.expiresIn,
    this.refreshToken,
    this.oneLogin,
    this.isOneLogin,
    this.raw = const <String, dynamic>{},
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
        accessToken: jsonString(json['access_token'] ?? json['token']) ?? '',
        rawToken: jsonString(json['token']),
        tokenType: jsonString(json['token_type']),
        expiresIn: jsonInt(json['expires_in']),
        refreshToken: jsonString(json['refresh_token']),
        oneLogin: jsonBool(json['one_login']),
        isOneLogin: jsonBool(json['is_one_login']),
        raw: json,
      );

  factory AuthToken.fromResponseJson(Object? json) {
    final map = jsonMap(json) ?? const <String, dynamic>{};
    final firstData = jsonMap(map['data']) ?? map;
    final tokenMap = jsonMap(firstData['data']) ?? firstData;
    return AuthToken.fromJson(tokenMap);
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        if (rawToken != null) 'token': rawToken,
        if (tokenType != null) 'token_type': tokenType,
        if (expiresIn != null) 'expires_in': expiresIn,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (oneLogin != null) 'one_login': oneLogin,
        if (isOneLogin != null) 'is_one_login': isOneLogin,
        ...raw,
      };
}

bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

String _orEmpty(String? value) => value?.trim() ?? '';

class CaptchaData {
  final String captchaKey;
  final String captchaImageContent;
  final String? captchaImg;
  final String? captchaCode;

  const CaptchaData({
    required this.captchaKey,
    this.captchaImageContent = '',
    this.captchaImg,
    this.captchaCode,
  });

  factory CaptchaData.fromJson(Map<String, dynamic> json) => CaptchaData(
        captchaKey: jsonString(json['captcha_key']) ?? '',
        captchaImageContent: jsonString(json['captcha_image_content']) ?? '',
        captchaImg: jsonString(json['captcha_img']),
        captchaCode: jsonString(json['captcha_code']),
      );

  Map<String, dynamic> toJson() => {
        'captcha_key': captchaKey,
        'captcha_image_content': captchaImageContent,
        if (captchaImg != null) 'captcha_img': captchaImg,
        if (captchaCode != null) 'captcha_code': captchaCode,
      };

  String? get imageContent {
    final candidates = <String?>[
      captchaImg,
      captchaImageContent,
      captchaCode,
    ];
    for (final candidate in candidates) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}

class VerificationCodeData {
  final String message;
  final String? code;
  final String? key;
  final String? captchaImg;
  final String? captchaCode;
  final int? expire;

  const VerificationCodeData({
    this.message = 'auth.codeSent',
    this.code,
    this.key,
    this.captchaImg,
    this.captchaCode,
    this.expire,
  });

  factory VerificationCodeData.fromJson(Map<String, dynamic> json) {
    return VerificationCodeData(
      message: jsonString(json['msg'] ?? json['message']) ?? 'auth.codeSent',
      code: jsonString(json['code']),
      key: jsonString(json['captcha_key'] ?? json['key']),
      captchaImg: jsonString(json['captcha_img']),
      captchaCode: jsonString(json['captcha_code']),
      expire: jsonInt(json['expire']),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        if (code != null) 'code': code,
        if (key != null) 'captcha_key': key,
        if (captchaImg != null) 'captcha_img': captchaImg,
        if (captchaCode != null) 'captcha_code': captchaCode,
        if (expire != null) 'expire': expire,
      };

  CaptchaData? get captcha {
    final captchaKey = key?.trim();
    if (captchaKey == null || captchaKey.isEmpty) return null;
    return CaptchaData(
      captchaKey: captchaKey,
      captchaImg: captchaImg,
      captchaCode: captchaCode,
    );
  }
}

class ResetPasswordRequest {
  final int type;
  final String? areaCode;
  final String? phone;
  final String? email;
  final String? realName;
  final String? payPassword;
  final String? code;
  final String password;

  const ResetPasswordRequest({
    required this.type,
    this.areaCode,
    this.phone,
    this.email,
    this.realName,
    this.payPassword,
    this.code,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (areaCode != null) 'area_code': areaCode,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (realName != null) 'real_name': realName,
        if (payPassword != null) 'pay_password': payPassword,
        if (code != null) 'code': code,
        'password': password,
      };
}

class TelegramLoginRequest {
  final String userId;
  final String username;

  const TelegramLoginRequest({required this.userId, required this.username});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'username': username,
      };
}

class SetTelegramPasswordRequest {
  final String newPassword;
  final String confirmPassword;

  const SetTelegramPasswordRequest({
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'newPass': newPassword,
        'confirmpass': confirmPassword,
      };
}
