import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key, this.width, this.height, this.radius});

  final double? width;
  final double? height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height ?? 16.h,
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(radius ?? 8.r),
      ),
    );
  }
}
