import 'package:dio/dio.dart';

import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final data = response.data;
    if (data is Map) {
      final code = data['code'];
      final normalizedCode =
          code is int ? code : int.tryParse(code?.toString() ?? '');
      if (normalizedCode != null && normalizedCode != 200) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: ApiException(
              type: _isUnauthorized(normalizedCode)
                  ? ApiExceptionType.unauthorized
                  : ApiExceptionType.business,
              message: (data['msg'] ?? data['message'] ?? 'Business error')
                  .toString(),
              statusCode: response.statusCode,
              businessCode: normalizedCode,
            ),
          ),
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(_normalize(err));
  }

  DioException _normalize(DioException err) {
    if (err.error is ApiException) {
      return err;
    }

    final exception = switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        ApiException(
          type: ApiExceptionType.timeout,
          message: 'Request timeout',
          statusCode: err.response?.statusCode,
          cause: err,
        ),
      DioExceptionType.connectionError => ApiException(
          type: ApiExceptionType.network,
          message: 'Network unavailable',
          statusCode: err.response?.statusCode,
          cause: err,
        ),
      DioExceptionType.cancel => ApiException(
          type: ApiExceptionType.cancel,
          message: 'Request cancelled',
          statusCode: err.response?.statusCode,
          cause: err,
        ),
      DioExceptionType.badResponse => ApiException(
          type: _isUnauthorized(err.response?.statusCode)
              ? ApiExceptionType.unauthorized
              : ApiExceptionType.http,
          message: err.response?.statusMessage ?? 'HTTP error',
          statusCode: err.response?.statusCode,
          cause: err,
        ),
      _ => ApiException(
          type: ApiExceptionType.unknown,
          message: err.message ?? 'Unknown network error',
          statusCode: err.response?.statusCode,
          cause: err,
        ),
    };

    return err.copyWith(error: exception);
  }

  bool _isUnauthorized(int? statusCode) =>
      statusCode == 401 || statusCode == 403;
}
