import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'common/localized_text.dart';

class CustomTabBarItem {
  final String label;
  final Widget icon;
  final Widget activeIcon;

  CustomTabBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class CustomTabBar extends StatelessWidget {
  final List<CustomTabBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  const CustomTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.backgroundColor = AppColors.surface,
    this.activeColor = AppColors.primary,
    this.inactiveColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isActive ? item.activeIcon : item.icon,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isActive ? activeColor : inactiveColor,
                          fontWeight:
                              isActive ? FontWeight.w500 : FontWeight.normal,
                          height: 1.05,
                        ),
                        maxLines: isBurmeseLocale(context) ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
