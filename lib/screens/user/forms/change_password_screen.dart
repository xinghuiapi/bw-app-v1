import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/user/user_models.dart';
import '../../../providers/user/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import 'user_form_feedback.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<UserProvider>().isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'security.changeLoginPassword'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'security.oldPassword'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'security.enterOldPassword'.tr(),
                controller: _oldPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              Text(
                'security.newPassword'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'security.enterNewPasswordRule'.tr(),
                controller: _newPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              Text(
                'security.confirmNewPassword'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'security.enterNewPasswordAgain'.tr(),
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: isSubmitting
                    ? 'common.submitting'.tr()
                    : 'common.confirmEdit'.tr(),
                isLoading: isSubmitting,
                onPressed: isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      _showMessage('security.enterOldPassword'.tr());
      return;
    }
    if (newPassword.isEmpty) {
      _showMessage('security.enterNewPassword'.tr());
      return;
    }
    if (newPassword.length < 6) {
      _showMessage('security.newPasswordMinLength'.tr());
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage('security.newPasswordMismatch'.tr());
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider.changePassword(
        ChangePasswordRequest(
          currentPass: oldPassword,
          newPass: newPassword,
          confirmPass: confirmPassword,
        ),
      );
      if (!mounted) return;
      _showMessage('security.passwordChanged'.tr());
      context.canPop() ? context.pop() : context.go('/setting');
    } catch (error) {
      if (!mounted) return;
      _showMessage(
          userFormErrorMessage(error, 'security.passwordChangeFailed'.tr()));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
