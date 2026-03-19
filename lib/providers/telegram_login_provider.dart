import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/models/auth_models.dart';
import 'package:my_flutter_app/services/auth_service.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';

part 'telegram_login_provider.g.dart';

enum TelegramLoginStep {
  idle,
  loggingIn,
  settingPassword,
  fetchingUserInfo,
  success,
  failed,
}

class TelegramLoginState {
  final TelegramLoginStep step;
  final String? error;
  final bool isFirstLogin;

  const TelegramLoginState({
    this.step = TelegramLoginStep.idle,
    this.error,
    this.isFirstLogin = false,
  });

  TelegramLoginState copyWith({
    TelegramLoginStep? step,
    String? error,
    bool? isFirstLogin,
  }) {
    return TelegramLoginState(
      step: step ?? this.step,
      error: error ?? this.error,
      isFirstLogin: isFirstLogin ?? this.isFirstLogin,
    );
  }
}

@riverpod
class TelegramLoginNotifier extends _$TelegramLoginNotifier {
  @override
  TelegramLoginState build() {
    return const TelegramLoginState();
  }

  Future<void> login(String userId, String username) async {
    state = state.copyWith(step: TelegramLoginStep.loggingIn, error: null);

    try {
      // 1. Telegram Login
      final loginResponse = await AuthService.telegramLogin(
        TelegramLoginRequest(userId: userId, username: username),
      );

      if (!loginResponse.isSuccess || loginResponse.data == null) {
        state = state.copyWith(
          step: TelegramLoginStep.failed,
          error: loginResponse.msg ?? 'Login failed',
        );
        return;
      }

      final authData = loginResponse.data!;
      final bool isFirstLogin =
          authData.oneLogin == true || authData.isOneLogin == true;

      // 2. Save Token
      await AuthHelper.setToken(authData.accessToken);
      if (authData.refreshToken != null) {
        await AuthHelper.setRefreshToken(authData.refreshToken!);
      }
      ref.read(authProvider.notifier).updateLoginState(authData.accessToken);

      state = state.copyWith(isFirstLogin: isFirstLogin);

      // 3. Set Default Password if First Login
      if (isFirstLogin) {
        state = state.copyWith(step: TelegramLoginStep.settingPassword);
        final pwdResponse = await AuthService.setTelegramPassword(
          SetTelegramPasswordRequest(newPass: '123456', confirmPass: '123456'),
        );

        if (!pwdResponse.isSuccess) {
          // Even if password setting fails, we might still be logged in.
          // But according to original project, we should handle it.
          // Here we continue but log the error.
          print('Warning: Setting default password failed: ${pwdResponse.msg}');
        }
      }

      // 4. Fetch User Info
      state = state.copyWith(step: TelegramLoginStep.fetchingUserInfo);
      await ref.read(userProvider.notifier).fetchUserInfo();

      state = state.copyWith(step: TelegramLoginStep.success);
    } catch (e) {
      state = state.copyWith(
        step: TelegramLoginStep.failed,
        error: e.toString(),
      );
    }
  }
}
