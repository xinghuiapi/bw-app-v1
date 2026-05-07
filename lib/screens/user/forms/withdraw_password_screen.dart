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
import 'user_form_feedback.dart';

class WithdrawPasswordScreen extends StatefulWidget {
  const WithdrawPasswordScreen({super.key});

  @override
  State<WithdrawPasswordScreen> createState() => _WithdrawPasswordScreenState();
}

class _WithdrawPasswordScreenState extends State<WithdrawPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
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
      appBar: CustomNavBar(title: isSet ? '修改资金密码' : '设置资金密码'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '为了您的资金安全，请设置资金密码。',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                '资金密码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请输入6位纯数字密码',
                controller: _passwordController,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              Text(
                '确认密码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请再次输入资金密码',
                controller: _confirmController,
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: isSubmitting ? '提交中...' : '确认提交',
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      _showMessage('请输入6位纯数字密码');
      return;
    }
    if (password != confirm) {
      _showMessage('两次输入的资金密码不一致');
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider
          .setPayPassword(SetPayPasswordRequest(payPassword: password));
      if (!mounted) return;
      _showMessage('设置成功');
      context.pop();
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, '设置失败'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
