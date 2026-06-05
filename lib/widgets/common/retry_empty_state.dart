import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

class RetryEmptyState extends StatelessWidget {
  const RetryEmptyState({
    super.key,
    required this.message,
    required this.onRetry,
    this.height,
    this.compact = false,
  });

  final String message;
  final VoidCallback onRetry;
  final double? height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth.clamp(0.0, 320.w)
            : 320.w;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 20.w : 28.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NetworkIllustration(compact: compact),
                  SizedBox(height: compact ? 8.h : 14.h),
                  Text(
                    _title(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: compact ? 14.sp : 16.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: compact ? 3.h : 6.h),
                  Text(
                    _displayMessage(context),
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: compact ? 12.sp : 13.sp,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: compact ? 10.h : 16.h),
                  _RetryButton(onPressed: onRetry, compact: compact),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (height == null) return content;
    return SizedBox(
      height: height,
      child: content,
    );
  }

  String _title(BuildContext context) {
    final text = message.trim().toLowerCase();
    if (text.contains('network') || text.contains('timeout')) {
      return 'common.loadFailed'.tr();
    }
    return 'common.loadFailed'.tr();
  }

  String _displayMessage(BuildContext context) {
    final text = message.trim();
    if (text.isEmpty) return 'common.loadFailedRetry'.tr();
    if (text == 'Network unavailable') return 'common.loadFailedRetry'.tr();
    if (text == 'Request timeout') return 'common.loadFailedRetry'.tr();
    return text;
  }
}

class _NetworkIllustration extends StatelessWidget {
  const _NetworkIllustration({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 54.w : 74.w;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  const Color(0xFFFFFFFF).withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          Positioned(
            top: compact ? 7.h : 10.h,
            right: compact ? 8.w : 11.w,
            child: Container(
              width: compact ? 8.w : 10.w,
              height: compact ? 8.w : 10.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.26),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: compact ? 34.w : 46.w,
            height: compact ? 34.w : 46.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.13),
                  blurRadius: 18.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: AppColors.primary,
              size: compact ? 19.sp : 25.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed, required this.compact});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 36.h : 42.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: compact ? 26.w : 36.w),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: compact ? 17.sp : 19.sp),
            SizedBox(width: 5.w),
            Text(
              'common.retry'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 14.sp : 16.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
