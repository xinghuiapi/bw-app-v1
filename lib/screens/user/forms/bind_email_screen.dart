import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/countdown_button.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '绑定邮箱'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  onPressed: () async {
                    // TODO: Implement send code logic
                    await Future.delayed(const Duration(seconds: 1));
                    return true; // Return true to start countdown
                  },
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '确认绑定',
                onPressed: () {
                  // TODO: Implement bind email logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
