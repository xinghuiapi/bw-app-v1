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

class WithdrawPasswordScreen extends StatefulWidget {
  const WithdrawPasswordScreen({super.key});

  @override
  State<WithdrawPasswordScreen> createState() => _WithdrawPasswordScreenState();
}

class _WithdrawPasswordScreenState extends State<WithdrawPasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final isSet = provider.profile?.hasPayPassword ?? false;
    final isSubmitting = provider.isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: isSet
            ? 'security.editFundPassword'.tr()
            : 'security.setFundPassword'.tr(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'security.fundPasswordTip'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              if (isSet) ...[
                Text(
                  _securityText('oldFundPassword', 'Old withdrawal password'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: _securityText(
                    'enterOldFundPassword',
                    'Enter old withdrawal password',
                  ),
                  controller: _oldPasswordController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                SizedBox(height: 24.h),
              ],
              Text(
                'security.fundPassword'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'security.enterFundPassword'.tr(),
                controller: _passwordController,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              Text(
                'security.confirmFundPassword'.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: 'security.enterFundPasswordAgain'.tr(),
                controller: _confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: isSubmitting
                    ? 'common.submitting'.tr()
                    : 'common.confirmSubmit'.tr(),
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
    final provider = context.read<UserProvider>();
    final isSet = provider.profile?.hasPayPassword ?? false;
    final oldPassword = _oldPasswordController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (isSet && !RegExp(r'^\d{6}$').hasMatch(oldPassword)) {
      _showMessage(
        _securityText(
          'enterOldFundPassword',
          'Enter old withdrawal password',
        ),
      );
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      _showMessage('security.enterFundPassword'.tr());
      return;
    }
    if (password != confirm) {
      _showMessage('security.fundPasswordMismatch'.tr());
      return;
    }

    if (provider.isSubmitting) return;
    try {
      await provider
          .setPayPassword(SetPayPasswordRequest(payPassword: password));
      if (!mounted) return;
      _showMessage('security.setSuccess'.tr());
      context.canPop() ? context.pop() : context.go('/setting');
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, 'security.setFailed'.tr()));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _securityText(String key, String fallback) {
    final localeKey = 'security.$key';
    final value = localeKey.tr();
    return value == localeKey ? fallback : value;
  }
}
