import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'app_language.dart';

class FallbackAssetLoader extends AssetLoader {
  const FallbackAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final attempted = <String>[];
    for (final localePath in _candidatePaths(path, locale)) {
      try {
        final value = await rootBundle.loadString(localePath);
        if (kDebugMode) debugPrint('[i18n] loaded $localePath');
        return _decode(value);
      } catch (_) {
        attempted.add(localePath);
      }
    }

    final fallbackPath = '$path/zh-CN.json';
    final value = await rootBundle.loadString(fallbackPath);
    if (kDebugMode) {
      debugPrint('[i18n] failed ${attempted.join(', ')}, loaded $fallbackPath');
    }
    return _decode(value);
  }

  List<String> _candidatePaths(String path, Locale locale) {
    final mappedName = switch (AppLanguage.fromLocale(locale)) {
      'TW' => 'zh-TW',
      'MY' => 'my-MM',
      'EN' => 'en-US',
      'JP' => 'ja-JP',
      'KR' => 'ko-KR',
      'TH' => 'th-TH',
      'VN' => 'vi-VN',
      _ => 'zh-CN',
    };
    final country = locale.countryCode;
    final rawNames = <String>{
      locale.toStringWithSeparator(separator: '-'),
      locale.toString(),
      if (country != null && country.isNotEmpty)
        '${locale.languageCode}-$country',
      mappedName,
    };
    return rawNames.map((name) => '$path/$name.json').toList();
  }

  Map<String, dynamic> _decode(String value) {
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }
}
