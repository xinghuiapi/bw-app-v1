import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/system/system_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, this.redirectPath});

  final String? redirectPath;

  @override
  Widget build(BuildContext context) {
    final site = context.watch<SystemProvider>().config.siteConfig;
    final title = site?.title?.trim();
    final description = site?.desc?.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 48.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                title?.isNotEmpty == true ? title! : '系统维护中',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                description?.isNotEmpty == true
                    ? description!
                    : '平台正在进行系统维护，请稍后再试。',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              CustomButton(
                text: '重新检测',
                onPressed: () => _retry(context),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () => context.go('/'),
                child: Text(
                  '返回首页',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _retry(BuildContext context) async {
    final provider = context.read<SystemProvider>();
    await provider.loadConfig(refresh: true);
    if (!context.mounted) return;
    final isMaintaining = provider.config.siteConfig?.status == 0;
    if (isMaintaining) return;
    final target = redirectPath?.trim();
    context.go(target?.isNotEmpty == true ? target! : '/');
  }
}
