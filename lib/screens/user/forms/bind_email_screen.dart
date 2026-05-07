import 'package:flutter/material.dart';
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
      appBar: const CustomNavBar(title: '绑定邮箱'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBound) ...[
                _BoundStatusCard(
                  icon: Icons.email_outlined,
                  title: '邮箱已绑定',
                  value: _maskEmail(profile!.email!),
                  message: '当前账号已绑定邮箱，暂不支持在此页面修改。',
                ),
                SizedBox(height: 24.h),
                CustomButton(text: '返回', onPressed: () => context.pop()),
              ] else ...[
                Text(
                  '邮箱地址',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: '请输入邮箱地址',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24.h),
                Text(
                  '验证码',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: '请输入邮箱验证码',
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  suffixIcon: CountdownButton(
                    onPressed: _sendCode,
                  ),
                ),
                SizedBox(height: 48.h),
                CustomButton(
                  text: isSubmitting ? '绑定中...' : '确认绑定',
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
      _showMessage('请输入正确邮箱');
      return;
    }
    if (code.isEmpty) {
      _showMessage('请输入验证码');
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider.updateProfile(
        UserProfileUpdateRequest(email: email, code: code),
      );
      if (!mounted) return;
      _showMessage('绑定成功');
      context.pop();
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, '绑定失败'));
    }
  }

  Future<bool> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_isEmail(email)) {
      _showMessage('请输入正确邮箱');
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
      _showMessage(userFormErrorMessage(error, '验证码发送失败'));
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
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
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
