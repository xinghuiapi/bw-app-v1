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
  final Map<String, dynamic>? mailConfig;
  @JsonKey(name: 'config_send')
  final Map<String, dynamic>? sendConfig;
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

  factory HomeData.fromJson(Map<String, dynamic> json) => _$HomeDataFromJson(json);
  Map<String, dynamic> toJson() => _$HomeDataToJson(this);
}

@JsonSerializable()
class RegConfig {
  final String? name;
  final String? title;
  final int? status; // 1: 显示, 0: 隐藏
  @JsonKey(name: 'is_required')
  final int? isRequired; // 1: 必填, 0: 选填

  RegConfig({this.name, this.title, this.status, this.isRequired});

  factory RegConfig.fromJson(Map<String, dynamic> json) => _$RegConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RegConfigToJson(this);
}

@JsonSerializable()
class PicConfig {
  final int? status; // 1: 开启图形验证码, 0: 关闭

  PicConfig({this.status});

  factory PicConfig.fromJson(Map<String, dynamic> json) => _$PicConfigFromJson(json);
  Map<String, dynamic> toJson() => _$PicConfigToJson(this);
}

@JsonSerializable()
class LangConfig {
  final String? name;
  final String? code;
  final String? img;

  LangConfig({this.name, this.code, this.img});

  factory LangConfig.fromJson(Map<String, dynamic> json) => _$LangConfigFromJson(json);
  Map<String, dynamic> toJson() => _$LangConfigToJson(this);
}

@JsonSerializable()
class CurrConfig {
  final String? name;
  final String? code;

  CurrConfig({this.name, this.code});

  factory CurrConfig.fromJson(Map<String, dynamic> json) => _$CurrConfigFromJson(json);
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

  factory BannerModel.fromJson(Map<String, dynamic> json) => _$BannerModelFromJson(json);
  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}

@JsonSerializable()
class NoticeModel {
  final int? id;
  final String? title;
  @JsonKey(name: 'text')
  final String? content;

  NoticeModel({this.id, this.title, this.content});

  factory NoticeModel.fromJson(Map<String, dynamic> json) => _$NoticeModelFromJson(json);
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

  SiteConfig({
    this.title,
    this.logo,
    this.keyword,
    this.desc,
    this.status,
    this.serviceLink,
    this.appDownload,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) => _$SiteConfigFromJson(json);
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

  GameCategory({this.id, this.title, this.img, this.seImg, this.code, this.subCategories});

  factory GameCategory.fromJson(Map<String, dynamic> json) => _$GameCategoryFromJson(json);
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

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'] as int?,
      title: json['title'] as String?,
      h5Logo: (json['h5_logo'] as String?)?.trim(),
      pcLogo: (json['pc_logo'] as String?)?.trim(),
      gamecode: json['gamecode'] as String?,
      category: json['category'] as int?,
      statusS: json['status_s'] as int?,
      img: (json['img'] as String?)?.trim(),
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'h5_logo': h5Logo,
    'pc_logo': pcLogo,
    'gamecode': gamecode,
    'category': category,
    'status_s': statusS,
    'img': img,
    'label': label,
  };
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

  GameItem({
    this.id,
    this.title,
    this.img,
    this.gameCode,
    this.favorites,
    this.isCategoryResult,
    this.isHot,
  });

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
      isHot: _toBool(json['is_hot']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'img': img,
    'game_code': gameCode,
    'favorites': favorites,
    'is_category_result': isCategoryResult,
    'is_hot': isHot,
  };

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

  factory ActivityClass.fromJson(Map<String, dynamic> json) => _$ActivityClassFromJson(json);
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

  Activity({this.id, this.title, this.img, this.content, this.startAt, this.endAt, this.status});

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);
}

@JsonSerializable()
class FeedbackType {
  final int? id;
  final String? title;

  FeedbackType({this.id, this.title});

  factory FeedbackType.fromJson(Map<String, dynamic> json) => _$FeedbackTypeFromJson(json);
  Map<String, dynamic> toJson() => _$FeedbackTypeToJson(this);
}

@JsonSerializable()
class SinglePageClass {
  final int? id;
  final String? title;

  SinglePageClass({this.id, this.title});

  factory SinglePageClass.fromJson(Map<String, dynamic> json) => _$SinglePageClassFromJson(json);
  Map<String, dynamic> toJson() => _$SinglePageClassToJson(this);
}

@JsonSerializable()
class SinglePageContent {
  final String? title;
  final String? content;

  SinglePageContent({this.title, this.content});

  factory SinglePageContent.fromJson(Map<String, dynamic> json) => _$SinglePageContentFromJson(json);
  Map<String, dynamic> toJson() => _$SinglePageContentToJson(this);
}
