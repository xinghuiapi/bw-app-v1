import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final int type; // 1普通登录，2邮箱登录，3手机号登录
  final String? username;
  final String? password;
  final String? email;
  @JsonKey(name: 'email_code')
  final String? emailCode;
  final String? phone;
  @JsonKey(name: 'area_code')
  final String? areaCode;
  @JsonKey(name: 'phone_code')
  final String? phoneCode;
  @JsonKey(name: 'captcha_code')
  final String? captchaCode;
  @JsonKey(name: 'captcha_key')
  final String? captchaKey;

  LoginRequest({
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

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String password;
  @JsonKey(name: 'o_password')
  final String oPassword;
  final String? currency;
  final String? phone;
  @JsonKey(name: 'area_code')
  final String? areaCode;
  @JsonKey(name: 'phone_code')
  final String? phoneCode;
  final String? email;
  final String? name;
  final int? qq;
  final String? telegram;
  @JsonKey(name: 'captcha_code')
  final String? captchaCode;
  @JsonKey(name: 'captcha_key')
  final String? captchaKey;
  @JsonKey(name: 'email_code')
  final String? emailCode;
  final String? invicode;
  @JsonKey(name: 'pay_password')
  final String? payPassword;

  RegisterRequest({
    required this.username,
    required this.password,
    required this.oPassword,
    this.currency = 'CNY',
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
    this.invicode = '',
    this.payPassword,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class AuthResponseData {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String? tokenType;
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  AuthResponseData({
    required this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.refreshToken,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) => _$AuthResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseDataToJson(this);
}

@JsonSerializable()
class CaptchaData {
  @JsonKey(name: 'captcha_key')
  final String captchaKey;
  @JsonKey(name: 'captcha_image_content')
  final String captchaImageContent; // Note: API might return 'captcha_img' or similar, check usage. Doc said captcha_img?
  // Re-checking doc: "captcha_img": "data:image/jpeg;base64..."
  // Previous code had captchaImageContent, maybe mapped manually?
  // Let's check AuthService.getCaptcha implementation in previous Read.
  // It used CaptchaData.fromJson. I should check if key matches.
  // Doc: "captcha_img". Previous Read: "captcha_image_content".
  // I will add alias.
  @JsonKey(name: 'captcha_img')
  final String? captchaImg;

  CaptchaData({
    required this.captchaKey,
    this.captchaImageContent = '',
    this.captchaImg,
  });

  factory CaptchaData.fromJson(Map<String, dynamic> json) => _$CaptchaDataFromJson(json);
  Map<String, dynamic> toJson() => _$CaptchaDataToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final int type; // 1手机号验证码找回，2邮箱验证码找回，3真实姓名+安全密码找回
  @JsonKey(name: 'area_code')
  final String? areaCode;
  final String? phone;
  final String? email;
  @JsonKey(name: 'real_name')
  final String? realName;
  @JsonKey(name: 'pay_password')
  final String? payPassword;
  final String? code; // 手机 or 邮箱验证码
  final String password; // 新密码

  ResetPasswordRequest({
    required this.type,
    this.areaCode,
    this.phone,
    this.email,
    this.realName,
    this.payPassword,
    this.code,
    required this.password,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}
