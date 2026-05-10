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
      appBar: const CustomNavBar(title: '修改登录密码'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '原密码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请输入原登录密码',
                controller: _oldPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              Text(
                '新密码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请输入新密码（6-16位字母和数字）',
                controller: _newPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 24.h),
              Text(
                '确认新密码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请再次输入新密码',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: isSubmitting ? '提交中...' : '确认修改',
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
      _showMessage('请输入原登录密码');
      return;
    }
    if (newPassword.isEmpty) {
      _showMessage('请输入新密码');
      return;
    }
    if (newPassword.length < 6) {
      _showMessage('新密码不能少于6位');
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage('两次输入的新密码不一致');
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
      _showMessage('密码修改成功');
      context.canPop() ? context.pop() : context.go('/setting');
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, '密码修改失败'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
