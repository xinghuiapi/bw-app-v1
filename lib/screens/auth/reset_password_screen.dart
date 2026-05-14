import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/auth/auth_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: context.tr('auth.resetPassword'),
        backgroundColor: Colors.transparent,
        border: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('auth.forgotPasswordTitle'),
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.tr('auth.resetPasswordDesc'),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            CustomTextField(
              controller: _phoneController,
              hintText: context.tr('auth.enterPhone'),
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(
                Icons.phone_android,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _codeController,
                    hintText: context.tr('auth.code'),
                    keyboardType: TextInputType.number,
                    prefixIcon: Icon(
                      Icons.security,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed:
                        context.watch<AuthProvider>().isSendingResetCode ||
                                _countdown > 0
                            ? null
                            : _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      _countdown > 0
                          ? 'common.reacquireCountdown'.tr(
                              namedArgs: {'seconds': '$_countdown'},
                            )
                          : context.tr('auth.getCode'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _passwordController,
              hintText: context.tr('auth.enterNewPassword'),
              obscureText: true,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: context.watch<AuthProvider>().isResettingPassword
                  ? 'common.submitting'.tr()
                  : context.tr('auth.resetPassword'),
              onPressed: context.watch<AuthProvider>().isResettingPassword
                  ? null
                  : _submitReset,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack(context.tr('auth.enterPhone'));
      return;
    }
    try {
      await context.read<AuthProvider>().sendResetPasswordCode(
            type: 1,
            areaCode: '+86',
            phone: phone,
          );
      if (!mounted) return;
      _startCountdown();
      _showSnack(context.tr('auth.codeSent'));
    } catch (_) {
      if (!mounted) return;
      _showSnack(context.read<AuthProvider>().error ??
          context.tr('common.loadFailed'));
    }
  }

  Future<void> _submitReset() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text.trim();
    if (phone.isEmpty) {
      _showSnack(context.tr('auth.enterPhone'));
      return;
    }
    if (code.isEmpty) {
      _showSnack(context.tr('auth.enterCode'));
      return;
    }
    if (password.isEmpty) {
      _showSnack(context.tr('auth.enterNewPassword'));
      return;
    }
    try {
      await context.read<AuthProvider>().resetPassword(
            ResetPasswordRequest(
              type: 1,
              areaCode: '+86',
              phone: phone,
              code: code,
              password: password,
            ),
          );
      if (!mounted) return;
      _showSnack(context.tr('common.save'));
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      _showSnack(context.read<AuthProvider>().error ??
          context.tr('common.loadFailed'));
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        return;
      }
      setState(() => _countdown -= 1);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
