import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
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
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      context.tr('auth.getCode'),
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
              text: context.tr('auth.resetPassword'),
              onPressed: () {
                context.canPop() ? context.pop() : context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
