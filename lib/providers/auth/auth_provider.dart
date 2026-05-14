import '../../api/token_storage.dart';
import '../../api/dio_client.dart';
import '../../models/auth/auth_models.dart';
import '../../services/auth/auth_service.dart';
import '../base_provider.dart';

class AuthProvider extends BaseProvider<void> {
  AuthProvider({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    _authService = AuthService(DioClient(tokenStorage: _tokenStorage));
  }

  final TokenStorage _tokenStorage;
  late AuthService _authService;
  bool isInitialized = false;
  bool isAuthenticated = false;
  String? accessToken;
  CaptchaData? captcha;
  bool isCaptchaLoading = false;
  bool isSendingSmsCode = false;
  bool isSendingEmailCode = false;

  void bindClient(DioClient client) {
    _authService = AuthService(client);
  }

  Future<void> init() async {
    final token = await _tokenStorage.readAccessToken();
    isAuthenticated = token != null && token.isNotEmpty;
    accessToken = token;
    isInitialized = true;
    notifyListeners();
  }

  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiresIn,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
    isAuthenticated = accessToken != null && accessToken.isNotEmpty;
    this.accessToken = accessToken;
    notifyListeners();
  }

  Future<void> login(LoginRequest request) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final token = await _authService.login(request);
      await saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        tokenType: token.tokenType,
        expiresIn: token.expiresIn,
      );
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequest request) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final token = await _authService.register(request);
      await saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        tokenType: token.tokenType,
        expiresIn: token.expiresIn,
      );
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadCaptcha() async {
    if (isCaptchaLoading) return;
    isCaptchaLoading = true;
    notifyListeners();

    try {
      captcha = await _authService.getCaptcha();
    } finally {
      isCaptchaLoading = false;
      notifyListeners();
    }
  }

  void applyCaptcha(CaptchaData captchaData) {
    captcha = captchaData;
    notifyListeners();
  }

  Future<VerificationCodeData> sendSmsCode({
    required String phone,
    required String areaCode,
    int type = 1,
  }) async {
    if (isSendingSmsCode) {
      return const VerificationCodeData(message: 'auth.codeSending');
    }
    isSendingSmsCode = true;
    error = null;
    notifyListeners();

    try {
      return await _authService.sendSmsCode(
        phone: phone,
        areaCode: areaCode,
        type: type,
      );
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isSendingSmsCode = false;
      notifyListeners();
    }
  }

  Future<VerificationCodeData> sendEmailCode({
    required String email,
    int type = 1,
    String? username,
  }) async {
    if (isSendingEmailCode) {
      return const VerificationCodeData(message: 'auth.codeSending');
    }
    isSendingEmailCode = true;
    error = null;
    notifyListeners();

    try {
      return await _authService.sendEmailCode(
        email: email,
        type: type,
        username: username,
      );
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isSendingEmailCode = false;
      notifyListeners();
    }
  }

  Future<void> clearAuth() async {
    await _tokenStorage.clear();
    isAuthenticated = false;
    accessToken = null;
    captcha = null;
    notifyListeners();
  }

  Future<void> logout() async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (err) {
      error = err.toString();
    } finally {
      await _tokenStorage.clear();
      isAuthenticated = false;
      accessToken = null;
      captcha = null;
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> forceLogout() => clearAuth();
}
