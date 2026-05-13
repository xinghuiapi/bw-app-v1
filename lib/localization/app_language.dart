import 'package:flutter/widgets.dart';

class AppLanguage {
  const AppLanguage._();

  static const fallbackCode = 'CN';
  static const storageKey = 'lang';

  static const supportedCodes = <String>[
    'CN',
    'TW',
    'MY',
    'EN',
    'JP',
    'KR',
    'TH',
    'VN',
  ];

  static const supportedLocales = <Locale>[
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('my', 'MM'),
    Locale('en', 'US'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
    Locale('th', 'TH'),
    Locale('vi', 'VN'),
  ];

  static String normalize(String? raw) {
    final value = raw?.trim().toUpperCase() ?? '';
    if (value.isEmpty) return fallbackCode;
    if (value == 'CN' || value == 'ZH' || value == 'ZH-CN') return 'CN';
    if (value == 'TW' ||
        value == 'TC' ||
        value == 'ZH-TW' ||
        value == 'ZH-HK') {
      return 'TW';
    }
    if (value == 'MY' || value == 'MM' || value == 'MYANMAR') return 'MY';
    if (value == 'EN' || value == 'EN-US' || value == 'EN-GB') return 'EN';
    if (value == 'JP' || value == 'JA' || value == 'JA-JP') return 'JP';
    if (value == 'KR' || value == 'KO' || value == 'KO-KR') return 'KR';
    if (value == 'TH' || value == 'TH-TH') return 'TH';
    if (value == 'VN' || value == 'VI' || value == 'VI-VN') return 'VN';
    return fallbackCode;
  }

  static Locale toLocale(String code) {
    switch (normalize(code)) {
      case 'TW':
        return const Locale('zh', 'TW');
      case 'MY':
        return const Locale('my', 'MM');
      case 'EN':
        return const Locale('en', 'US');
      case 'JP':
        return const Locale('ja', 'JP');
      case 'KR':
        return const Locale('ko', 'KR');
      case 'TH':
        return const Locale('th', 'TH');
      case 'VN':
        return const Locale('vi', 'VN');
      case 'CN':
      default:
        return const Locale('zh', 'CN');
    }
  }

  static String fromLocale(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toUpperCase();
    if (language == 'zh' && country == 'TW') return 'TW';
    if (language == 'my') return 'MY';
    if (language == 'en') return 'EN';
    if (language == 'ja') return 'JP';
    if (language == 'ko') return 'KR';
    if (language == 'th') return 'TH';
    if (language == 'vi') return 'VN';
    return 'CN';
  }
}
