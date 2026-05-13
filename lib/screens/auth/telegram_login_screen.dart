import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_nav_bar.dart';
import '../../widgets/custom_button.dart';

class TelegramLoginScreen extends StatelessWidget {
  const TelegramLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(
        title: context.tr('auth.telegramLogin'),
        backgroundColor: Colors.transparent,
        border: false,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.telegram,
                size: 80.sp,
                color: Colors.blue,
              ),
              SizedBox(height: 24.h),
              Text(
                context.tr('auth.telegramQuickLogin'),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                context.tr('auth.telegramAgreement'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: context.tr('auth.authorizeTelegram'),
                onPressed: () {
                  context.go('/');
                },
              ),
              SizedBox(height: 16.h),
              CustomButton(
                text: context.tr('common.cancel'),
                isPrimary: false,
                onPressed: () {
                  context.canPop() ? context.pop() : context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
