import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_flutter_app/services/auth/auth_service.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';

part 'password_reset_provider.g.dart';

enum PasswordResetType {
  phone(1),
  email(2),
  realName(3);

  final int value;
  const PasswordResetType(this.value);
}

class PasswordResetState {
  final PasswordResetType type;
  final String phone;
  final String areaCode;
  final String email;
  final String realName;
  final String payPassword;
  final String code;
  final String password;
  final String confirmPassword;
  final bool isLoading;
  final int countdown;
  final String? error;

  PasswordResetState({
    this.type = PasswordResetType.phone,
    this.phone = '',
    this.areaCode = '86',
    this.email = '',
    this.realName = '',
    this.payPassword = '',
    this.code = '',
    this.password = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.countdown = 0,
    this.error,
  });

  PasswordResetState copyWith({
    PasswordResetType? type,
    String? phone,
    String? areaCode,
    String? email,
    String? realName,
    String? payPassword,
    String? code,
    String? password,
    String? confirmPassword,
    bool? isLoading,
    int? countdown,
    String? error,
  }) {
    return PasswordResetState(
      type: type ?? this.type,
      phone: phone ?? this.phone,
      areaCode: areaCode ?? this.areaCode,
      email: email ?? this.email,
      realName: realName ?? this.realName,
      payPassword: payPassword ?? this.payPassword,
      code: code ?? this.code,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      countdown: countdown ?? this.countdown,
      error: error ?? this.error,
    );
  }
}

@riverpod
class PasswordResetNotifier extends _$PasswordResetNotifier {
  Timer? _timer;

  @override
  PasswordResetState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return PasswordResetState();
  }

  void setType(PasswordResetType type) {
    state = state.copyWith(type: type, error: null);
  }

  void updateField({
    String? phone,
    String? areaCode,
    String? email,
    String? realName,
    String? payPassword,
    String? code,
    String? password,
    String? confirmPassword,
  }) {
    state = state.copyWith(
      phone: phone,
      areaCode: areaCode,
      email: email,
      realName: realName,
      payPassword: payPassword,
      code: code,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<void> sendCode() async {
    if (state.countdown > 0 || state.isLoading) return;

    if (state.type == PasswordResetType.phone) {
      if (state.phone.isEmpty) {
        ToastUtils.showError('请输入手机号');
        return;
      }
    } else if (state.type == PasswordResetType.email) {
      if (state.email.isEmpty) {
        ToastUtils.showError('请输入邮箱');
        return;
      }
    }

    state = state.copyWith(isLoading: true, error: null);

    final response = await AuthService.sendResetPasswordCode(
      type: state.type.value,
      phone: state.type == PasswordResetType.phone ? state.phone : null,
      areaCode: state.type == PasswordResetType.phone ? state.areaCode : null,
      email: state.type == PasswordResetType.email ? state.email : null,
    );

    state = state.copyWith(isLoading: false);

    if (response.isSuccess) {
      ToastUtils.showSuccess('验证码已发送');
      _startCountdown();
    } else {
      ToastUtils.showError(response.msg ?? '发送失败');
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    state = state.copyWith(countdown: 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown > 0) {
        state = state.copyWith(countdown: state.countdown - 1);
      } else {
        timer.cancel();
      }
    });
  }

  Future<bool> resetPassword() async {
    if (state.isLoading) return false;

    // 基础校验
    if (state.password.isEmpty) {
      ToastUtils.showError('请输入新密码');
      return false;
    }
    if (state.password != state.confirmPassword) {
      ToastUtils.showError('两次密码输入不一致');
      return false;
    }

    if (state.type == PasswordResetType.phone) {
      if (state.phone.isEmpty || state.code.isEmpty) {
        ToastUtils.showError('请输入手机号和验证码');
        return false;
      }
    } else if (state.type == PasswordResetType.email) {
      if (state.email.isEmpty || state.code.isEmpty) {
        ToastUtils.showError('请输入邮箱和验证码');
        return false;
      }
    } else if (state.type == PasswordResetType.realName) {
      if (state.realName.isEmpty || state.payPassword.isEmpty) {
        ToastUtils.showError('请输入真实姓名和安全密码');
        return false;
      }
    }

    state = state.copyWith(isLoading: true, error: null);

    final response = await AuthService.resetPassword(
      type: state.type.value,
      phone: state.phone,
      areaCode: state.areaCode,
      email: state.email,
      realName: state.realName,
      payPassword: state.payPassword,
      code: state.code,
      password: state.password,
    );

    state = state.copyWith(isLoading: false);

    if (response.isSuccess) {
      ToastUtils.showSuccess('密码重置成功');
      return true;
    } else {
      ToastUtils.showError(response.msg ?? '重置失败');
      return false;
    }
  }
}
