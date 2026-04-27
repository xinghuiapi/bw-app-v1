import 'package:dio/dio.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';

class AuthInterceptor extends QueuedInterceptor {
  final Dio dio;
  String? _currentLang;

  AuthInterceptor(this.dio);

  void updateLanguage(String lang) {
    _currentLang = lang;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await AuthHelper.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 仅在未设置 lang 头时设置默认值
    if (!options.headers.containsKey('lang')) {
      options.headers['lang'] = _currentLang ?? 'CN';
    }

    return handler.next(options);
  }
}
