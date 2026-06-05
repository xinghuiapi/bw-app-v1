import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'common/back_hit_target.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? leftText;
  final String? rightText;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final VoidCallback? onClickLeft;
  final VoidCallback? onClickRight;
  final bool showLeftArrow;
  final Color backgroundColor;
  final bool border;
  final bool fixed;
  final bool placeholder;
  final double leftHitTargetWidth;

  const CustomNavBar({
    super.key,
    required this.title,
    this.leftText,
    this.rightText,
    this.leftIcon,
    this.rightIcon,
    this.onClickLeft,
    this.onClickRight,
    this.showLeftArrow = true,
    this.backgroundColor = AppColors.surface,
    this.border = true,
    this.fixed = true,
    this.placeholder = true,
    this.leftHitTargetWidth = backHitTargetSize,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: topPadding + 46.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border
            ? const Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 60.w,
              right: 60.w,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  title,
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClickLeft ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: backHitTargetSize,
                  ).copyWith(minWidth: leftHitTargetWidth),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showLeftArrow)
                        leftIcon ??
                            Icon(
                              Icons.arrow_back_ios_new,
                              size: 16.sp,
                              color: AppColors.textPrimary,
                            ),
                      if (leftText != null)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Text(
                            leftText!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onClickRight,
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: backHitTargetSize,
                    minWidth: backHitTargetSize,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (rightText != null)
                        Text(
                          rightText!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (rightIcon != null)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: rightIcon!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final topPadding = view.padding.top / view.devicePixelRatio;
    return Size.fromHeight(topPadding + 46.h);
  }
}
