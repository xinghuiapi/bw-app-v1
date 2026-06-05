import '../core/json_utils.dart';

class HomeConfig {
  final List<BannerModel> banners;
  final List<NoticeModel> notices;
  final SiteConfig? siteConfig;
  final List<RegisterFieldConfig> registerConfig;
  final CaptchaConfig? captchaConfig;
  final VerifyConfig? mailConfig;
  final VerifyConfig? smsConfig;
  final List<LanguageConfig> languages;
  final List<CurrencyConfig> currencies;
  final List<CustomerServiceItem> customerServiceItems;

  const HomeConfig({
    this.banners = const [],
    this.notices = const [],
    this.siteConfig,
    this.registerConfig = const [],
    this.captchaConfig,
    this.mailConfig,
    this.smsConfig,
    this.languages = const [],
    this.currencies = const [],
    this.customerServiceItems = const [],
  });

  factory HomeConfig.fromJson(Map<String, dynamic> json) => HomeConfig(
        banners: jsonList(json['config_banner'], BannerModel.fromJson),
        notices: jsonList(json['config_notice'], NoticeModel.fromJson),
        siteConfig: jsonMap(json['config_site']) == null
            ? null
            : SiteConfig.fromJson(jsonMap(json['config_site'])!),
        registerConfig:
            jsonList(json['config_reg'], RegisterFieldConfig.fromJson),
        captchaConfig: jsonMap(json['config_pic']) == null
            ? null
            : CaptchaConfig.fromJson(jsonMap(json['config_pic'])!),
        mailConfig: jsonMap(json['config_mail']) == null
            ? null
            : VerifyConfig.fromJson(jsonMap(json['config_mail'])!),
        smsConfig: jsonMap(json['config_send']) == null
            ? null
            : VerifyConfig.fromJson(jsonMap(json['config_send'])!),
        languages: jsonList(json['config_lang'], LanguageConfig.fromJson),
        currencies: jsonList(json['config_curr'], CurrencyConfig.fromJson),
        customerServiceItems:
            jsonList(json['config_kefu'], CustomerServiceItem.fromJson)
                .where((item) => item.link.isNotEmpty)
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'config_banner': banners.map((item) => item.toJson()).toList(),
        'config_notice': notices.map((item) => item.toJson()).toList(),
        if (siteConfig != null) 'config_site': siteConfig!.toJson(),
        'config_reg': registerConfig.map((item) => item.toJson()).toList(),
        if (captchaConfig != null) 'config_pic': captchaConfig!.toJson(),
        if (mailConfig != null) 'config_mail': mailConfig!.toJson(),
        if (smsConfig != null) 'config_send': smsConfig!.toJson(),
        'config_lang': languages.map((item) => item.toJson()).toList(),
        'config_curr': currencies.map((item) => item.toJson()).toList(),
        'config_kefu':
            customerServiceItems.map((item) => item.toJson()).toList(),
      };
}

class CustomerServiceItem {
  final String title;
  final String link;
  final String icon;

  const CustomerServiceItem({
    required this.title,
    required this.link,
    required this.icon,
  });

  factory CustomerServiceItem.fromJson(Map<String, dynamic> json) {
    return CustomerServiceItem(
      title: _normalizeCustomerServiceText(json['title']),
      link: _normalizeCustomerServiceText(json['link']),
      icon: _normalizeCustomerServiceText(json['icon']),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'icon': icon,
      };
}

String _normalizeCustomerServiceText(dynamic raw) {
  var value = raw?.toString() ?? '';
  value = value.replaceAll(RegExp(r'[\uFE00-\uFE0F\u200D]'), '');
  value = value.replaceAll(RegExp(r'[✕✖❌]'), '×');
  value = value.replaceAll('`', '').trim();
  value = value.replaceAll(RegExp(r'''^['"]|['"]$'''), '').trim();
  value = value.replaceAll(RegExp(r'\s+'), '');
  return value;
}

class BannerModel {
  final String? img;
  final String? title;
  final String? openUrl;
  final int? open;
  final int? terminal;
  final List<String> languages;

  const BannerModel({
    this.img,
    this.title,
    this.openUrl,
    this.open,
    this.terminal,
    this.languages = const [],
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        img: jsonString(json['img']),
        title: jsonString(json['title']),
        openUrl: jsonString(json['open_url'] ?? json['url'] ?? json['link']),
        open: jsonInt(json['open']),
        terminal: jsonInt(json['terminal']),
        languages: _parseLanguageList(json['lang']),
      );

  Map<String, dynamic> toJson() => {
        if (img != null) 'img': img,
        if (title != null) 'title': title,
        if (openUrl != null) 'open_url': openUrl,
        if (open != null) 'open': open,
        if (terminal != null) 'terminal': terminal,
        if (languages.isNotEmpty) 'lang': languages,
      };
}

List<String> _parseLanguageList(dynamic value) {
  if (value == null) return const [];
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  final raw = value.toString().trim();
  if (raw.isEmpty) return const [];
  final normalized = raw.replaceAll(RegExp(r'''^\[|\]$'''), '');
  return normalized
      .split(',')
      .map((item) => item.replaceAll(RegExp(r'''["'`]'''), '').trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

class NoticeModel {
  final int id;
  final String? title;
  final String? content;
  final int? popUp;
  final int? terminal;
  final int? top;
  final String? openUrl;
  final int? open;

  const NoticeModel({
    required this.id,
    this.title,
    this.content,
    this.popUp,
    this.terminal,
    this.top,
    this.openUrl,
    this.open,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
        id: jsonInt(json['id']) ?? 0,
        title: jsonString(json['title']),
        content: jsonString(json['text'] ?? json['content']),
        popUp: jsonInt(json['pop_up']),
        terminal: jsonInt(json['terminal']),
        top: jsonInt(json['top']),
        openUrl: jsonString(json['open_url'] ?? json['url'] ?? json['link']),
        open: jsonInt(json['open']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (content != null) 'text': content,
        if (popUp != null) 'pop_up': popUp,
        if (terminal != null) 'terminal': terminal,
        if (top != null) 'top': top,
        if (openUrl != null) 'open_url': openUrl,
        if (open != null) 'open': open,
      };
}

class SiteConfig {
  final String? title;
  final String? logo;
  final String? keyword;
  final String? desc;
  final int? status;
  final String? serviceLink;
  final String? appDownload;
  final int? terminalLogin;
  final String? appVersion;
  final String? domain;
  final String? pcUrl;
  final String? h5Url;
  final String? agentUrl;
  final String? apkDownload;
  final String? iosDownload;
  final String? description;
  final String? appIcon;
  final String? appDesc;
  final dynamic tgLink;

  const SiteConfig({
    this.title,
    this.logo,
    this.keyword,
    this.desc,
    this.status,
    this.serviceLink,
    this.appDownload,
    this.terminalLogin,
    this.appVersion,
    this.domain,
    this.pcUrl,
    this.h5Url,
    this.agentUrl,
    this.apkDownload,
    this.iosDownload,
    this.description,
    this.appIcon,
    this.appDesc,
    this.tgLink,
  });

  factory SiteConfig.fromJson(Map<String, dynamic> json) => SiteConfig(
        title: jsonString(json['title']),
        logo: jsonString(json['logo']),
        keyword: jsonString(json['keyword']),
        desc: jsonString(json['desc']),
        status: jsonInt(json['status']),
        serviceLink: jsonString(json['service_link']),
        appDownload: jsonString(json['app_download']),
        terminalLogin: jsonInt(json['terminal_login']),
        appVersion: jsonString(json['app_version']),
        domain: jsonString(json['domain']),
        pcUrl: jsonString(json['pc_url']),
        h5Url: jsonString(json['h5_url']),
        agentUrl: jsonString(json['agent_url']),
        apkDownload: jsonString(json['apk_download']),
        iosDownload: jsonString(json['ios_download']),
        description: jsonString(json['description']),
        appIcon: jsonString(json['app_icon']),
        appDesc: jsonString(json['app_desc']),
        tgLink: json['tg_link'],
      );

  List<String> get telegramLinks {
    final value = tgLink;
    if (value == null) return const [];
    if (value is List) return value.map((item) => item.toString()).toList();
    return value
        .toString()
        .split(RegExp(r'[,\n]'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (logo != null) 'logo': logo,
        if (keyword != null) 'keyword': keyword,
        if (desc != null) 'desc': desc,
        if (status != null) 'status': status,
        if (serviceLink != null) 'service_link': serviceLink,
        if (appDownload != null) 'app_download': appDownload,
        if (terminalLogin != null) 'terminal_login': terminalLogin,
        if (appVersion != null) 'app_version': appVersion,
        if (domain != null) 'domain': domain,
        if (pcUrl != null) 'pc_url': pcUrl,
        if (h5Url != null) 'h5_url': h5Url,
        if (agentUrl != null) 'agent_url': agentUrl,
        if (apkDownload != null) 'apk_download': apkDownload,
        if (iosDownload != null) 'ios_download': iosDownload,
        if (description != null) 'description': description,
        if (appIcon != null) 'app_icon': appIcon,
        if (appDesc != null) 'app_desc': appDesc,
        if (tgLink != null) 'tg_link': tgLink,
      };
}

class RegisterFieldConfig {
  final String? code;
  final String? title;
  final int? status;
  final int? requiredStatus;

  const RegisterFieldConfig({
    this.code,
    this.title,
    this.status,
    this.requiredStatus,
  });

  factory RegisterFieldConfig.fromJson(Map<String, dynamic> json) {
    return RegisterFieldConfig(
      code: jsonString(json['code']),
      title: jsonString(json['title']),
      status: jsonInt(json['status']),
      requiredStatus: jsonInt(json['status_s']),
    );
  }

  bool get isVisible => status == 1;
  bool get isRequired => requiredStatus == 1;

  Map<String, dynamic> toJson() => {
        if (code != null) 'code': code,
        if (title != null) 'title': title,
        if (status != null) 'status': status,
        if (requiredStatus != null) 'status_s': requiredStatus,
      };
}

class CaptchaConfig {
  final int? id;
  final int? loginStatus;
  final int? regStatus;
  final int? loginError;
  final int? codeType;
  final String? width;
  final String? height;
  final String? size;
  final String? digit;

  const CaptchaConfig({
    this.id,
    this.loginStatus,
    this.regStatus,
    this.loginError,
    this.codeType,
    this.width,
    this.height,
    this.size,
    this.digit,
  });

  factory CaptchaConfig.fromJson(Map<String, dynamic> json) => CaptchaConfig(
        id: jsonInt(json['id']),
        loginStatus: jsonInt(json['login_status']),
        regStatus: jsonInt(json['reg_status']),
        loginError: jsonInt(json['login_error']),
        codeType: jsonInt(json['code_type']),
        width: jsonString(json['pic_width']),
        height: jsonString(json['pic_height']),
        size: jsonString(json['pic_size']),
        digit: jsonString(json['pic_digit']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (loginStatus != null) 'login_status': loginStatus,
        if (regStatus != null) 'reg_status': regStatus,
        if (loginError != null) 'login_error': loginError,
        if (codeType != null) 'code_type': codeType,
        if (width != null) 'pic_width': width,
        if (height != null) 'pic_height': height,
        if (size != null) 'pic_size': size,
        if (digit != null) 'pic_digit': digit,
      };
}

class VerifyConfig {
  final int? id;
  final int? loginStatus;
  final int? regStatus;
  final int? type;
  final int? expire;
  final int? frequency;

  const VerifyConfig({
    this.id,
    this.loginStatus,
    this.regStatus,
    this.type,
    this.expire,
    this.frequency,
  });

  factory VerifyConfig.fromJson(Map<String, dynamic> json) => VerifyConfig(
        id: jsonInt(json['id']),
        loginStatus: jsonInt(json['login_status']),
        regStatus: jsonInt(json['reg_status']),
        type: jsonInt(json['type']),
        expire: jsonInt(json['expire']),
        frequency: jsonInt(json['frequency']),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (loginStatus != null) 'login_status': loginStatus,
        if (regStatus != null) 'reg_status': regStatus,
        if (type != null) 'type': type,
        if (expire != null) 'expire': expire,
        if (frequency != null) 'frequency': frequency,
      };
}

class LanguageConfig {
  final String? title;
  final String? code;
  final String? img;
  final int? requiredStatus;

  const LanguageConfig({this.title, this.code, this.img, this.requiredStatus});

  factory LanguageConfig.fromJson(Map<String, dynamic> json) => LanguageConfig(
        title: jsonString(json['title'] ?? json['name']),
        code: jsonString(json['code']),
        img: jsonString(json['img']),
        requiredStatus: jsonInt(json['status_s']),
      );

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (code != null) 'code': code,
        if (img != null) 'img': img,
        if (requiredStatus != null) 'status_s': requiredStatus,
      };
}

class CurrencyConfig {
  final String? code;
  final String? title;
  final String? symbol;
  final int? requiredStatus;

  const CurrencyConfig(
      {this.code, this.title, this.symbol, this.requiredStatus});

  factory CurrencyConfig.fromJson(Map<String, dynamic> json) => CurrencyConfig(
        code: jsonString(json['code']),
        title: jsonString(json['title']),
        symbol: jsonString(json['symbol']),
        requiredStatus: jsonInt(json['status_s']),
      );

  Map<String, dynamic> toJson() => {
        if (code != null) 'code': code,
        if (title != null) 'title': title,
        if (symbol != null) 'symbol': symbol,
        if (requiredStatus != null) 'status_s': requiredStatus,
      };
}
