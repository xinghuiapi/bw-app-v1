import '../../../api/api_exception.dart';

String userFormErrorMessage(Object error, String fallback) {
  if (error is ApiException) {
    final message = error.message.trim();
    return message.isEmpty ? fallback : message;
  }

  final message = error.toString().trim();
  if (message.isEmpty) return fallback;

  final apiExceptionMatch =
      RegExp(r'^ApiException\([^,]+,\s*(.*)\)$').firstMatch(message);
  if (apiExceptionMatch != null) {
    final apiMessage = apiExceptionMatch.group(1)?.trim();
    if (apiMessage != null && apiMessage.isNotEmpty) return apiMessage;
  }

  return message;
}
