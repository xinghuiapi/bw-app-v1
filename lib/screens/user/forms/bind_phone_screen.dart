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

class BindPhoneScreen extends StatefulWidget {
  const BindPhoneScreen({super.key});

  @override
  State<BindPhoneScreen> createState() => _BindPhoneScreenState();
}

class _BindPhoneScreenState extends State<BindPhoneScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final isBound = profile?.isPhoneBound ?? false;
    final isSubmitting = provider.isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '绑定手机号'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBound) ...[
                _BoundStatusCard(
                  icon: Icons.phone_iphone,
                  title: '手机号已绑定',
                  value: _maskPhone(profile!.phone!),
                  message: '当前账号已绑定手机号，暂不支持在此页面修改。',
                ),
                SizedBox(height: 24.h),
                CustomButton(text: '返回', onPressed: _exitPage),
              ] else ...[
                Text(
                  '手机号',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: '请输入手机号码',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
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
                  hintText: '请输入验证码',
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
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (!_isPhone(phone)) {
      _showMessage('请输入正确手机号');
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
        UserProfileUpdateRequest(phone: phone, areaCode: '+86', code: code),
      );
      if (!mounted) return;
      _showMessage('绑定成功');
      _exitPage();
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, '绑定失败'));
    }
  }

  Future<bool> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!_isPhone(phone)) {
      _showMessage('请输入正确手机号');
      return false;
    }

    try {
      final result = await context.read<UserProvider>().sendPhoneCode(
            phone: phone,
            areaCode: '+86',
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

  bool _isPhone(String value) => RegExp(r'^1\d{10}$').hasMatch(value);

  String _maskPhone(String value) {
    final text = value.trim();
    if (text.length < 7) return text;
    return '${text.substring(0, 3)}****${text.substring(text.length - 4)}';
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
