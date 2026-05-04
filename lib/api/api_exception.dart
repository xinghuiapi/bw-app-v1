enum ApiExceptionType {
  network,
  timeout,
  http,
  unauthorized,
  business,
  parse,
  cancel,
  unknown
}

class ApiException implements Exception {
  final ApiExceptionType type;
  final String message;
  final int? statusCode;
  final int? businessCode;
  final Object? cause;

  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.businessCode,
    this.cause,
  });

  bool get isUnauthorized => type == ApiExceptionType.unauthorized;

  @override
  String toString() => 'ApiException($type, $message)';
}
