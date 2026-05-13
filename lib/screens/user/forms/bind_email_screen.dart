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
import '../../../widgets/countdown_button.dart';
import 'user_form_feedback.dart';

class BindEmailScreen extends StatefulWidget {
  const BindEmailScreen({super.key});

  @override
  State<BindEmailScreen> createState() => _BindEmailScreenState();
}

class _BindEmailScreenState extends State<BindEmailScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final isBound = profile?.isEmailBound ?? false;
    final isSubmitting = provider.isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'account.bindEmail'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBound) ...[
                _BoundStatusCard(
                  icon: Icons.email_outlined,
                  title: 'account.emailBoundTitle'.tr(),
                  value: _maskEmail(profile!.email!),
                  message: 'account.emailBoundMessage'.tr(),
                ),
                SizedBox(height: 24.h),
                CustomButton(text: 'common.back'.tr(), onPressed: _exitPage),
              ] else ...[
                Text(
                  'account.emailAddress'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: 'account.enterValidEmail'.tr(),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24.h),
                Text(
                  'account.verifyCode'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: 'account.enterVerifyCode'.tr(),
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  suffixIcon: CountdownButton(
                    onPressed: _sendCode,
                  ),
                ),
                SizedBox(height: 48.h),
                CustomButton(
                  text: isSubmitting
                      ? 'common.binding'.tr()
                      : 'common.confirmBind'.tr(),
                  onPressed: _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (!_isEmail(email)) {
      _showMessage('account.enterValidEmail'.tr());
      return;
    }
    if (code.isEmpty) {
      _showMessage('account.enterVerifyCode'.tr());
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider.updateProfile(
        UserProfileUpdateRequest(email: email, code: code),
      );
      if (!mounted) return;
      _showMessage('account.bindSuccess'.tr());
      _exitPage();
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, 'account.bindFailed'.tr()));
    }
  }

  Future<bool> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_isEmail(email)) {
      _showMessage('account.enterValidEmail'.tr());
      return false;
    }

    try {
      final result = await context.read<UserProvider>().sendEmailCode(
            email: email,
          );
      if (!mounted) return false;
      _showMessage(result.message);
      return true;
    } catch (error) {
      if (!mounted) return false;
      _showMessage(userFormErrorMessage(error, 'account.sendCodeFailed'.tr()));
      return false;
    }
  }

  bool _isEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

  String _maskEmail(String value) {
    final text = value.trim();
    final atIndex = text.indexOf('@');
    if (atIndex <= 1) return text;
    return '${text.substring(0, 1)}***${text.substring(atIndex)}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _exitPage() {
    context.canPop() ? context.pop() : context.go('/profile');
  }
}

class _BoundStatusCard extends StatelessWidget {
  const _BoundStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String value;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
