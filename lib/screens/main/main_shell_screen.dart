import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/game/game_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_tab_bar.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomTabBar(
        currentIndex: navigationShell.currentIndex,
        onChanged: (index) => _handleTabChanged(context, index),
        items: [
          CustomTabBarItem(
            label: '首页',
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '游戏大厅',
            icon: Icon(Icons.videogame_asset_outlined, size: 24.sp),
            activeIcon: Icon(
              Icons.videogame_asset,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          CustomTabBarItem(
            label: '活动',
            icon: Icon(Icons.card_giftcard_outlined, size: 24.sp),
            activeIcon: Icon(
              Icons.card_giftcard,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          CustomTabBarItem(
            label: '客服',
            icon: Icon(Icons.headset_mic_outlined, size: 24.sp),
            activeIcon: Icon(
              Icons.headset_mic,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          CustomTabBarItem(
            label: '我的',
            icon: Icon(Icons.person_outline, size: 24.sp),
            activeIcon:
                Icon(Icons.person, size: 24.sp, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _handleTabChanged(BuildContext context, int index) {
    if (index == 1) {
      context.read<GameProvider>().loadCategories(refresh: true);
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
