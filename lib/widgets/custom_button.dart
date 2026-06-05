import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'common/localized_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final double? width;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return Container(
      width: width ?? double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: enabled
            ? (isPrimary ? AppColors.primary : AppColors.surface)
            : AppColors.textSecondary.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24.r),
        border: isPrimary ? null : Border.all(color: AppColors.border),
        boxShadow: isPrimary && enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.r),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              child: isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isPrimary ? Colors.white : AppColors.textPrimary,
                      ),
                    )
                  : LocalizedOneLineText(
                      key: const ValueKey('text'),
                      text: text,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
