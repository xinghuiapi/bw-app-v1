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
  bool isSendingResetCode = false;
  bool isResettingPassword = false;
  bool isTelegramLoggingIn = false;
  bool isSettingTelegramPassword = false;

  void bindClient(DioClient client) {
    _authService = AuthService(client);
  }

  Future<void> init() async {
    final token = await _tokenStorage.readAccessToken();
    if (isAuthenticated && accessToken?.isNotEmpty == true) {
      isInitialized = true;
      notifyListeners();
      return;
    }
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

  Future<VerificationCodeData> sendResetPasswordCode({
    required int type,
    String? areaCode,
    String? phone,
    String? email,
  }) async {
    if (isSendingResetCode) {
      return const VerificationCodeData(message: 'auth.codeSending');
    }
    isSendingResetCode = true;
    error = null;
    notifyListeners();

    try {
      return await _authService.sendResetPasswordCode(
        type: type,
        areaCode: areaCode,
        phone: phone,
        email: email,
      );
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isSendingResetCode = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    if (isResettingPassword) return;
    isResettingPassword = true;
    error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(request);
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isResettingPassword = false;
      notifyListeners();
    }
  }

  Future<AuthToken?> telegramLogin(TelegramLoginRequest request) async {
    if (isTelegramLoggingIn) return null;
    isTelegramLoggingIn = true;
    error = null;
    notifyListeners();

    try {
      final token = await _authService.telegramLogin(request);
      if (token.accessToken.trim().isEmpty) {
        throw Exception('auth.telegramLogin.missingToken');
      }
      await saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        tokenType: token.tokenType,
        expiresIn: token.expiresIn,
      );
      return token;
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isTelegramLoggingIn = false;
      notifyListeners();
    }
  }

  Future<void> setTelegramPassword(SetTelegramPasswordRequest request) async {
    if (isSettingTelegramPassword) return;
    isSettingTelegramPassword = true;
    error = null;
    notifyListeners();

    try {
      await _authService.setTelegramPassword(request);
    } catch (err) {
      error = err.toString();
      rethrow;
    } finally {
      isSettingTelegramPassword = false;
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
