import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/game/game_provider.dart';
import '../../providers/game/floating_game_provider.dart';
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
      body: Stack(
        children: [
          navigationShell,
          const _FloatingGameBubble(),
        ],
      ),
      bottomNavigationBar: CustomTabBar(
        currentIndex: navigationShell.currentIndex,
        onChanged: (index) => _handleTabChanged(context, index),
        items: [
          CustomTabBarItem(
            label: context.tr('nav.home'),
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: context.tr('nav.game'),
            icon: Icon(Icons.videogame_asset_outlined, size: 24.sp),
            activeIcon: Icon(
              Icons.videogame_asset,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          CustomTabBarItem(
            label: context.tr('nav.activity'),
            icon: Icon(Icons.card_giftcard_outlined, size: 24.sp),
            activeIcon: Icon(
              Icons.card_giftcard,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          CustomTabBarItem(
            label: context.tr('nav.service'),
            icon: Icon(Icons.headset_mic_outlined, size: 24.sp),
            activeIcon: Icon(
              Icons.headset_mic,
              size: 24.sp,
              color: AppColors.primary,
            ),
          ),
          CustomTabBarItem(
            label: context.tr('nav.profile'),
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

class _FloatingGameBubble extends StatelessWidget {
  const _FloatingGameBubble();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FloatingGameProvider>();
    if (!provider.hasGame) return const SizedBox.shrink();
    final title = provider.title?.trim().isNotEmpty == true
        ? provider.title!.trim()
        : 'game.title'.tr();
    final bottom = MediaQuery.paddingOf(context).bottom + 76.h;
    return Positioned(
      right: 14.w,
      bottom: bottom,
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => provider.close(),
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.68),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 15.sp, color: Colors.white),
              ),
            ),
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: () {
                final url = provider.url?.trim();
                if (url == null || url.isEmpty) return;
                context.push('/game-view', extra: {
                  'url': url,
                  'title': title,
                });
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: 150.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4AA3FF), Color(0xFF1677FF)],
                  ),
                  borderRadius: BorderRadius.circular(22.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.26),
                      blurRadius: 12.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_esports,
                        size: 18.sp, color: Colors.white),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
