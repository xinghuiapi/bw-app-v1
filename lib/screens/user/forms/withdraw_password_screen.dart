import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '设置资金密码'),
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
                text: '确认提交',
                onPressed: () {
                  // TODO: Implement set withdraw password logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
