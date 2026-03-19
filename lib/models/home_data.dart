import 'package:json_annotation/json_annotation.dart';

part 'home_data.g.dart';

@JsonSerializable()
class HomeData {
  @JsonKey(name: 'config_banner')
  final List<BannerModel>? banners;
  @JsonKey(name: 'config_notice')
  final List<NoticeModel>? notices;
  @JsonKey(name: 'config_site')
  final SiteConfig? siteConfig;
  @JsonKey(name: 'config_reg')
  final List<RegConfig>? regConfig;
  @JsonKey(name: 'config_pic')
  final PicConfig? picConfig;
  @JsonKey(name: 'config_mail')
  final MailConfig? mailConfig;
  @JsonKey(name: 'config_send')
  final SendConfig? sendConfig;
  @JsonKey(name: 'config_lang')
  final List<LangConfig>? langConfig;
  @JsonKey(name: 'config_curr')
  final List<CurrConfig>? currConfig;

  HomeData({
    this.banners,
    this.notices,
    this.siteConfig,
    this.regConfig,
    this.picConfig,
    this.mailConfig,
    this.sendConfig,
    this.langConfig,
    this.currConfig,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) =>
      _$HomeDataFromJson(json);
  Map<String, dynamic> toJson() => _$HomeDataToJson(this);
}

@JsonSerializable()
class RegConfig {
  final String? code;
  final String? title;
  final int? status; // 1: 显示, 0: 隐藏
  @JsonKey(name: 'status_s')
  final int? statusS; // 1: 必填, 0: 选填

  RegConfig({this.code, this.title, this.status, this.statusS});

  factory RegConfig.fromJson(Map<String, dynamic> json) =>
      _$RegConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RegConfigToJson(this);
}

@JsonSerializable()
class PicConfig {
  final int? id;
  @JsonKey(name: 'login_status')
  final int? loginStatus;
  @JsonKey(name: 'reg_status')
  final int? regStatus;
  @JsonKey(name: 'agent_login_status')
  final int? agentLoginStatus;
  @JsonKey(name: 'admin_login_status')
  final int? adminLoginStatus;
  @JsonKey(name: 'login_error')
  final int? loginError;
  @JsonKey(name: 'code_type')
  final int? codeType; // 1: 图形, 0: 滑行
  @JsonKey(name: 'pic_width')
  final String? picWidth;
  @JsonKey(name: 'pic_height')
  final String? picHeight;
  @JsonKey(name: 'pic_size')
  final String? picSize;
  @JsonKey(name: 'pic_digit')
  final String? picDigit;

  PicConfig({
    this.id,
    this.loginStatus,
    this.regStatus,
    this.agentLoginStatus,
    this.adminLoginStatus,
    this.loginError,
    this.codeType,
    this.picWidth,
    this.picHeight,
    this.picSize,
    this.picDigit,
  });

  factory PicConfig.fromJson(Map<String, dynamic> json) =>
      _$PicConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PicConfigToJson(this);
}

@JsonSerializable()
class MailConfig {
  final int? id;
  @JsonKey(name: 'login_status')
  final int? loginStatus;
  @JsonKey(name: 'reg_status')
  final int? regStatus;
  @JsonKey(name: 'agent_login_status')
  final int? agentLoginStatus;
  @JsonKey(name: 'admin_login_status')
  final int? adminLoginStatus;
  final int? type;
  final int? expire;
  final int? frequency;

  MailConfig({
    this.id,
    this.loginStatus,
    this.regStatus,
    this.agentLoginStatus,
    this.adminLoginStatus,
    this.type,
    this.expire,
    this.frequency,
  });

  factory MailConfig.fromJson(Map<String, dynamic> json) =>
      _$MailConfigFromJson(json);
  Map<String, dynamic> toJson() => _$MailConfigToJson(this);
}

@JsonSerializable()
class SendConfig {
  final int? id;
  @JsonKey(name: 'login_status')
  final int? loginStatus;
  @JsonKey(name: 'reg_status')
  final int? regStatus;
  @JsonKey(name: 'agent_login_status')
  final int? agentLoginStatus;
  @JsonKey(name: 'admin_login_status')
  final int? adminLoginStatus;
  final int? type;
  final int? expire;
  final int? frequency;

  SendConfig({
    this.id,
    this.loginStatus,
    this.regStatus,
    this.agentLoginStatus,
    this.adminLoginStatus,
    this.type,
    this.expire,
    this.frequency,
  });

  factory SendConfig.fromJson(Map<String, dynamic> json) =>
      _$SendConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SendConfigToJson(this);
}

@JsonSerializable()
class LangConfig {
  final String? name;
  final String? code;
  final String? img;

  LangConfig({this.name, this.code, this.img});

  factory LangConfig.fromJson(Map<String, dynamic> json) =>
      _$LangConfigFromJson(json);
  Map<String, dynamic> toJson() => _$LangConfigToJson(this);
}

@JsonSerializable()
class CurrConfig {
  final String? code;
  final String? title;
  final String? symbol;
  @JsonKey(name: 'status_s')
  final int? statusS;

  CurrConfig({this.code, this.title, this.symbol, this.statusS});

  factory CurrConfig.fromJson(Map<String, dynamic> json) =>
      _$CurrConfigFromJson(json);
  Map<String, dynamic> toJson() => _$CurrConfigToJson(this);
}

@JsonSerializable()
class BannerModel {
  final String? img;
  final String? title;
  @JsonKey(name: 'open_url')
  final String? openUrl;
  final int? open;

  BannerModel({this.img, this.title, this.openUrl, this.open});

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}

@JsonSerializable()
class NoticeModel {
  final int? id;
  final String? title;
  @JsonKey(name: 'text')
  final String? content;

  NoticeModel({this.id, this.title, this.content});

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);
  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);
}

@JsonSerializable()
class SiteConfig {
  final String? title;
  final String? logo;
  final String? keyword;
  final String? desc;
  final int? status;
  @JsonKey(name: 'service_link')
  final String? serviceLink;
  @JsonKey(name: 'app_download')
  final String? appDownload;
  @JsonKey(name: 'terminal_login')
  final int? terminalLogin;
  @JsonKey(name: 'app_version')
  final String? appVersion;

  // tg_link 可能是字符串，也可能是数组，所以这里使用 dynamic，然后在 getter 中处理
  @JsonKey(name: 'tg_link')
  final dynamic tgLink;

  List<String> get tgLinks {
    if (tgLink == null) return [];
    if (tgLink is String) {
      if (tgLink.toString().isEmpty) return [];
      return tgLink
          .toString()
          .split(RegExp(r'[,\n]'))
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    if (tgLink is List) {
      return (tgLink as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }
    return [];
  }

  SiteConfig({
    this.title,
    this.logo,
    this.keyword,
    this.desc,
    this.status,
    this.serviceLink,
    this.appDownload,
    this.terminalLogin,
    this.appVersion,
    this.tgLink,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) =>
      _$SiteConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SiteConfigToJson(this);
}

@JsonSerializable()
class GameCategory {
  final int? id;
  final String? title;
  final String? img;
  @JsonKey(name: 'se_img')
  final String? seImg;
  final String? code;
  final List<SubCategory>? subCategories;

  GameCategory({
    this.id,
    this.title,
    this.img,
    this.seImg,
    this.code,
    this.subCategories,
  });

  factory GameCategory.fromJson(Map<String, dynamic> json) =>
      _$GameCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$GameCategoryToJson(this);
}

@JsonSerializable()
class SubCategory {
  final int? id;
  final String? title;
  @JsonKey(name: 'h5_logo')
  final String? h5Logo;
  @JsonKey(name: 'pc_logo')
  final String? pcLogo;
  final String? gamecode;
  final int? category;
  @JsonKey(name: 'status_s')
  final int? statusS;
  final String? img; // for reco data
  final String? label; // for reco data

  SubCategory({
    this.id,
    this.title,
    this.h5Logo,
    this.pcLogo,
    this.gamecode,
    this.category,
    this.statusS,
    this.img,
    this.label,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$SubCategoryToJson(this);
}

@JsonSerializable()
class GameItem {
  final int? id;
  final String? title;
  final String? img;
  @JsonKey(name: 'game_code')
  final String? gameCode;
  final dynamic favorites;
  @JsonKey(name: 'is_category_result')
  final bool? isCategoryResult;
  @JsonKey(name: 'is_hot')
  final bool? isHot;
  @JsonKey(name: 'interface_title')
  final String? interfaceTitle;
  final List<String>? label;

  GameItem({
    this.id,
    this.title,
    this.img,
    this.gameCode,
    this.favorites,
    this.isCategoryResult,
    this.isHot,
    this.interfaceTitle,
    this.label,
  });

  bool get isFavorite =>
      favorites == 1 ||
      favorites == true ||
      favorites == '1' ||
      favorites == 'true';

  // 手动实现 fromJson 以处理数据类型不一致的问题
  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      id: json['id'] as int?,
      title: json['title'] as String?,
      img: (json['img'] as String?)?.trim(),
      // 兼容 game_code 和 code
      gameCode: (json['game_code'] ?? json['code']) as String?,
      favorites: json['favorites'],
      // 兼容 bool 和 int (0/1)
      isCategoryResult: _toBool(json['is_category_result']),
      isHot: _toBool(
        json['is_hot'] ??
            (json['label'] is List && (json['label'] as List).contains('hot')),
      ),
      interfaceTitle: json['interface_title'] as String?,
      label: (json['label'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() => _$GameItemToJson(this);

  static bool? _toBool(dynamic val) {
    if (val == null) return null;
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val == '1' || val == 'true';
    return false;
  }
}

@JsonSerializable()
class ActivityClass {
  final int? id;
  final String? title;
  final String? img;

  ActivityClass({this.id, this.title, this.img});

  factory ActivityClass.fromJson(Map<String, dynamic> json) =>
      _$ActivityClassFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityClassToJson(this);
}

@JsonSerializable()
class Activity {
  final int? id;
  final String? title;
  final String? img;
  final String? content;
  @JsonKey(name: 'start_at')
  final String? startAt;
  @JsonKey(name: 'end_at')
  final String? endAt;
  final int? status;

  Activity({
    this.id,
    this.title,
    this.img,
    this.content,
    this.startAt,
    this.endAt,
    this.status,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class FeedbackType {
  final int? id;
  final String? title;

  FeedbackType({this.id, this.title});

  factory FeedbackType.fromJson(Map<String, dynamic> json) =>
      _$FeedbackTypeFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackTypeToJson(this);
}

@JsonSerializable()
class SinglePageClass {
  final int? id;
  final String? title;

  SinglePageClass({this.id, this.title});

  factory SinglePageClass.fromJson(Map<String, dynamic> json) =>
      _$SinglePageClassFromJson(json);
  Map<String, dynamic> toJson() => _$SinglePageClassToJson(this);
}

@JsonSerializable()
class SinglePageContent {
  final String? title;
  final String? content;

  SinglePageContent({this.title, this.content});

  factory SinglePageContent.fromJson(Map<String, dynamic> json) =>
      _$SinglePageContentFromJson(json);
  Map<String, dynamic> toJson() => _$SinglePageContentToJson(this);
}
