import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class CustomCell extends StatelessWidget {
  final String title;
  final String? value;
  final String? label;
  final Widget? icon;
  final Widget? rightIcon;
  final bool isLink;
  final bool border;
  final VoidCallback? onTap;

  const CustomCell({
    super.key,
    required this.title,
    this.value,
    this.label,
    this.icon,
    this.rightIcon,
    this.isLink = false,
    this.border = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: isLink ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: border
                ? const Border(
                    bottom: BorderSide(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: label != null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: icon!,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (label != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          label!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (value != null)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    value!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              if (isLink || rightIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: rightIcon ??
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
