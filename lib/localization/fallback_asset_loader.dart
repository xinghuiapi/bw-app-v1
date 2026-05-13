import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FallbackAssetLoader extends AssetLoader {
  const FallbackAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final localePath =
        '$path/${locale.toStringWithSeparator(separator: '-')}.json';
    try {
      return _decode(await rootBundle.loadString(localePath));
    } catch (_) {
      return _decode(await rootBundle.loadString('$path/CN.json'));
    }
  }

  Map<String, dynamic> _decode(String value) {
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }
}
