// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeData _$HomeDataFromJson(Map<String, dynamic> json) => HomeData(
  banners: (json['config_banner'] as List<dynamic>?)
      ?.map((e) => BannerModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  notices: (json['config_notice'] as List<dynamic>?)
      ?.map((e) => NoticeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  siteConfig: json['config_site'] == null
      ? null
      : SiteConfig.fromJson(json['config_site'] as Map<String, dynamic>),
  regConfig: (json['config_reg'] as List<dynamic>?)
      ?.map((e) => RegConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
  picConfig: json['config_pic'] == null
      ? null
      : PicConfig.fromJson(json['config_pic'] as Map<String, dynamic>),
  mailConfig: json['config_mail'] == null
      ? null
      : MailConfig.fromJson(json['config_mail'] as Map<String, dynamic>),
  sendConfig: json['config_send'] == null
      ? null
      : SendConfig.fromJson(json['config_send'] as Map<String, dynamic>),
  langConfig: (json['config_lang'] as List<dynamic>?)
      ?.map((e) => LangConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
  currConfig: (json['config_curr'] as List<dynamic>?)
      ?.map((e) => CurrConfig.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HomeDataToJson(HomeData instance) => <String, dynamic>{
  'config_banner': instance.banners,
  'config_notice': instance.notices,
  'config_site': instance.siteConfig,
  'config_reg': instance.regConfig,
  'config_pic': instance.picConfig,
  'config_mail': instance.mailConfig,
  'config_send': instance.sendConfig,
  'config_lang': instance.langConfig,
  'config_curr': instance.currConfig,
};

RegConfig _$RegConfigFromJson(Map<String, dynamic> json) => RegConfig(
  code: json['code'] as String?,
  title: json['title'] as String?,
  status: (json['status'] as num?)?.toInt(),
  statusS: (json['status_s'] as num?)?.toInt(),
);

Map<String, dynamic> _$RegConfigToJson(RegConfig instance) => <String, dynamic>{
  'code': instance.code,
  'title': instance.title,
  'status': instance.status,
  'status_s': instance.statusS,
};

PicConfig _$PicConfigFromJson(Map<String, dynamic> json) => PicConfig(
  id: (json['id'] as num?)?.toInt(),
  loginStatus: (json['login_status'] as num?)?.toInt(),
  regStatus: (json['reg_status'] as num?)?.toInt(),
  agentLoginStatus: (json['agent_login_status'] as num?)?.toInt(),
  adminLoginStatus: (json['admin_login_status'] as num?)?.toInt(),
  loginError: (json['login_error'] as num?)?.toInt(),
  codeType: (json['code_type'] as num?)?.toInt(),
  picWidth: json['pic_width'] as String?,
  picHeight: json['pic_height'] as String?,
  picSize: json['pic_size'] as String?,
  picDigit: json['pic_digit'] as String?,
);

Map<String, dynamic> _$PicConfigToJson(PicConfig instance) => <String, dynamic>{
  'id': instance.id,
  'login_status': instance.loginStatus,
  'reg_status': instance.regStatus,
  'agent_login_status': instance.agentLoginStatus,
  'admin_login_status': instance.adminLoginStatus,
  'login_error': instance.loginError,
  'code_type': instance.codeType,
  'pic_width': instance.picWidth,
  'pic_height': instance.picHeight,
  'pic_size': instance.picSize,
  'pic_digit': instance.picDigit,
};

MailConfig _$MailConfigFromJson(Map<String, dynamic> json) => MailConfig(
  id: (json['id'] as num?)?.toInt(),
  loginStatus: (json['login_status'] as num?)?.toInt(),
  regStatus: (json['reg_status'] as num?)?.toInt(),
  agentLoginStatus: (json['agent_login_status'] as num?)?.toInt(),
  adminLoginStatus: (json['admin_login_status'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  expire: (json['expire'] as num?)?.toInt(),
  frequency: (json['frequency'] as num?)?.toInt(),
);

Map<String, dynamic> _$MailConfigToJson(MailConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login_status': instance.loginStatus,
      'reg_status': instance.regStatus,
      'agent_login_status': instance.agentLoginStatus,
      'admin_login_status': instance.adminLoginStatus,
      'type': instance.type,
      'expire': instance.expire,
      'frequency': instance.frequency,
    };

SendConfig _$SendConfigFromJson(Map<String, dynamic> json) => SendConfig(
  id: (json['id'] as num?)?.toInt(),
  loginStatus: (json['login_status'] as num?)?.toInt(),
  regStatus: (json['reg_status'] as num?)?.toInt(),
  agentLoginStatus: (json['agent_login_status'] as num?)?.toInt(),
  adminLoginStatus: (json['admin_login_status'] as num?)?.toInt(),
  type: (json['type'] as num?)?.toInt(),
  expire: (json['expire'] as num?)?.toInt(),
  frequency: (json['frequency'] as num?)?.toInt(),
);

Map<String, dynamic> _$SendConfigToJson(SendConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login_status': instance.loginStatus,
      'reg_status': instance.regStatus,
      'agent_login_status': instance.agentLoginStatus,
      'admin_login_status': instance.adminLoginStatus,
      'type': instance.type,
      'expire': instance.expire,
      'frequency': instance.frequency,
    };

LangConfig _$LangConfigFromJson(Map<String, dynamic> json) => LangConfig(
  name: json['name'] as String?,
  code: json['code'] as String?,
  img: json['img'] as String?,
);

Map<String, dynamic> _$LangConfigToJson(LangConfig instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'img': instance.img,
    };

CurrConfig _$CurrConfigFromJson(Map<String, dynamic> json) => CurrConfig(
  code: json['code'] as String?,
  title: json['title'] as String?,
  symbol: json['symbol'] as String?,
  statusS: (json['status_s'] as num?)?.toInt(),
);

Map<String, dynamic> _$CurrConfigToJson(CurrConfig instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'symbol': instance.symbol,
      'status_s': instance.statusS,
    };

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  img: json['img'] as String?,
  title: json['title'] as String?,
  openUrl: json['open_url'] as String?,
  open: (json['open'] as num?)?.toInt(),
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'img': instance.img,
      'title': instance.title,
      'open_url': instance.openUrl,
      'open': instance.open,
    };

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  content: json['text'] as String?,
);

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'text': instance.content,
    };

SiteConfig _$SiteConfigFromJson(Map<String, dynamic> json) => SiteConfig(
  title: json['title'] as String?,
  logo: json['logo'] as String?,
  keyword: json['keyword'] as String?,
  desc: json['desc'] as String?,
  status: (json['status'] as num?)?.toInt(),
  serviceLink: json['service_link'] as String?,
  appDownload: json['app_download'] as String?,
  terminalLogin: (json['terminal_login'] as num?)?.toInt(),
  appVersion: json['app_version'] as String?,
);

Map<String, dynamic> _$SiteConfigToJson(SiteConfig instance) =>
    <String, dynamic>{
      'title': instance.title,
      'logo': instance.logo,
      'keyword': instance.keyword,
      'desc': instance.desc,
      'status': instance.status,
      'service_link': instance.serviceLink,
      'app_download': instance.appDownload,
      'terminal_login': instance.terminalLogin,
      'app_version': instance.appVersion,
    };

GameCategory _$GameCategoryFromJson(Map<String, dynamic> json) => GameCategory(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  img: json['img'] as String?,
  seImg: json['se_img'] as String?,
  code: json['code'] as String?,
  subCategories: (json['subCategories'] as List<dynamic>?)
      ?.map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GameCategoryToJson(GameCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'img': instance.img,
      'se_img': instance.seImg,
      'code': instance.code,
      'subCategories': instance.subCategories,
    };

SubCategory _$SubCategoryFromJson(Map<String, dynamic> json) => SubCategory(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  h5Logo: json['h5_logo'] as String?,
  pcLogo: json['pc_logo'] as String?,
  gamecode: json['gamecode'] as String?,
  category: (json['category'] as num?)?.toInt(),
  statusS: (json['status_s'] as num?)?.toInt(),
  img: json['img'] as String?,
  label: json['label'] as String?,
);

Map<String, dynamic> _$SubCategoryToJson(SubCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'h5_logo': instance.h5Logo,
      'pc_logo': instance.pcLogo,
      'gamecode': instance.gamecode,
      'category': instance.category,
      'status_s': instance.statusS,
      'img': instance.img,
      'label': instance.label,
    };

GameItem _$GameItemFromJson(Map<String, dynamic> json) => GameItem(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  img: json['img'] as String?,
  gameCode: json['game_code'] as String?,
  favorites: json['favorites'],
  isCategoryResult: json['is_category_result'] as bool?,
  isHot: json['is_hot'] as bool?,
  interfaceTitle: json['interface_title'] as String?,
  label: (json['label'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$GameItemToJson(GameItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'img': instance.img,
  'game_code': instance.gameCode,
  'favorites': instance.favorites,
  'is_category_result': instance.isCategoryResult,
  'is_hot': instance.isHot,
  'interface_title': instance.interfaceTitle,
  'label': instance.label,
};

ActivityClass _$ActivityClassFromJson(Map<String, dynamic> json) =>
    ActivityClass(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      img: json['img'] as String?,
    );

Map<String, dynamic> _$ActivityClassToJson(ActivityClass instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'img': instance.img,
    };

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
  img: json['img'] as String?,
  content: json['content'] as String?,
  startAt: json['start_at'] as String?,
  endAt: json['end_at'] as String?,
  status: (json['status'] as num?)?.toInt(),
);

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'img': instance.img,
  'content': instance.content,
  'start_at': instance.startAt,
  'end_at': instance.endAt,
  'status': instance.status,
};

FeedbackType _$FeedbackTypeFromJson(Map<String, dynamic> json) => FeedbackType(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String?,
);

Map<String, dynamic> _$FeedbackTypeToJson(FeedbackType instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

SinglePageClass _$SinglePageClassFromJson(Map<String, dynamic> json) =>
    SinglePageClass(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$SinglePageClassToJson(SinglePageClass instance) =>
    <String, dynamic>{'id': instance.id, 'title': instance.title};

SinglePageContent _$SinglePageContentFromJson(Map<String, dynamic> json) =>
    SinglePageContent(
      title: json['title'] as String?,
      content: json['content'] as String?,
    );

Map<String, dynamic> _$SinglePageContentToJson(SinglePageContent instance) =>
    <String, dynamic>{'title': instance.title, 'content': instance.content};
