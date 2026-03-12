// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  type: (json['type'] as num).toInt(),
  username: json['username'] as String?,
  password: json['password'] as String?,
  email: json['email'] as String?,
  emailCode: json['email_code'] as String?,
  phone: json['phone'] as String?,
  areaCode: json['area_code'] as String?,
  phoneCode: json['phone_code'] as String?,
  captchaCode: json['captcha_code'] as String?,
  captchaKey: json['captcha_key'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'username': instance.username,
      'password': instance.password,
      'email': instance.email,
      'email_code': instance.emailCode,
      'phone': instance.phone,
      'area_code': instance.areaCode,
      'phone_code': instance.phoneCode,
      'captcha_code': instance.captchaCode,
      'captcha_key': instance.captchaKey,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      password: json['password'] as String,
      oPassword: json['o_password'] as String,
      currency: json['currency'] as String? ?? 'CNY',
      phone: json['phone'] as String?,
      areaCode: json['area_code'] as String?,
      phoneCode: json['phone_code'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      qq: (json['qq'] as num?)?.toInt(),
      telegram: json['telegram'] as String?,
      captchaCode: json['captcha_code'] as String?,
      captchaKey: json['captcha_key'] as String?,
      emailCode: json['email_code'] as String?,
      invicode: json['invicode'] as String? ?? '',
      payPassword: json['pay_password'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'o_password': instance.oPassword,
      'currency': instance.currency,
      'phone': instance.phone,
      'area_code': instance.areaCode,
      'phone_code': instance.phoneCode,
      'email': instance.email,
      'name': instance.name,
      'qq': instance.qq,
      'telegram': instance.telegram,
      'captcha_code': instance.captchaCode,
      'captcha_key': instance.captchaKey,
      'email_code': instance.emailCode,
      'invicode': instance.invicode,
      'pay_password': instance.payPassword,
    };

AuthResponseData _$AuthResponseDataFromJson(Map<String, dynamic> json) =>
    AuthResponseData(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String?,
      expiresIn: (json['expires_in'] as num?)?.toInt(),
      refreshToken: json['refresh_token'] as String?,
      oneLogin: json['one_login'] as bool?,
      isOneLogin: json['is_one_login'] as bool?,
    );

Map<String, dynamic> _$AuthResponseDataToJson(AuthResponseData instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'refresh_token': instance.refreshToken,
      'one_login': instance.oneLogin,
      'is_one_login': instance.isOneLogin,
    };

TelegramLoginRequest _$TelegramLoginRequestFromJson(
  Map<String, dynamic> json,
) => TelegramLoginRequest(
  userId: json['user_id'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$TelegramLoginRequestToJson(
  TelegramLoginRequest instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'username': instance.username,
};

SetTelegramPasswordRequest _$SetTelegramPasswordRequestFromJson(
  Map<String, dynamic> json,
) => SetTelegramPasswordRequest(
  newPass: json['newPass'] as String,
  confirmPass: json['confirmpass'] as String,
);

Map<String, dynamic> _$SetTelegramPasswordRequestToJson(
  SetTelegramPasswordRequest instance,
) => <String, dynamic>{
  'newPass': instance.newPass,
  'confirmpass': instance.confirmPass,
};

CaptchaData _$CaptchaDataFromJson(Map<String, dynamic> json) => CaptchaData(
  captchaKey: json['captcha_key'] as String,
  captchaImageContent: json['captcha_image_content'] as String? ?? '',
  captchaImg: json['captcha_img'] as String?,
);

Map<String, dynamic> _$CaptchaDataToJson(CaptchaData instance) =>
    <String, dynamic>{
      'captcha_key': instance.captchaKey,
      'captcha_image_content': instance.captchaImageContent,
      'captcha_img': instance.captchaImg,
    };

ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequest(
  type: (json['type'] as num).toInt(),
  areaCode: json['area_code'] as String?,
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  realName: json['real_name'] as String?,
  payPassword: json['pay_password'] as String?,
  code: json['code'] as String?,
  password: json['password'] as String,
);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  ResetPasswordRequest instance,
) => <String, dynamic>{
  'type': instance.type,
  'area_code': instance.areaCode,
  'phone': instance.phone,
  'email': instance.email,
  'real_name': instance.realName,
  'pay_password': instance.payPassword,
  'code': instance.code,
  'password': instance.password,
};
