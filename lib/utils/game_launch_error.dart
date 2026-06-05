import 'package:easy_localization/easy_localization.dart';

import '../api/api_exception.dart';

String gameLaunchErrorText(Object? error, String fallbackKey) {
  final message = switch (error) {
    ApiException(:final message) => message,
    String value => value,
    Object value => value.toString(),
    _ => fallbackKey.tr(),
  }
      .trim();
  return message.isEmpty ? fallbackKey.tr() : message;
}
