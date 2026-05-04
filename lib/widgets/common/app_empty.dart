import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    this.title = '暂无数据',
    this.description,
    this.action,
  });

  final String title;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56.w, color: AppColors.border),
            SizedBox(height: 12.h),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (description != null) ...[
              SizedBox(height: 8.h),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (action != null) ...[SizedBox(height: 16.h), action!],
          ],
        ),
      ),
    );
  }
}
