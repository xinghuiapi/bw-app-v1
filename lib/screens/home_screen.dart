import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/home/banner_widget.dart';
import '../widgets/home/notices_widget.dart';
import '../widgets/home/quick_access_widget.dart';
import '../widgets/home/game_categories_widget.dart';
import '../widgets/home/app_download_bar_widget.dart';
import '../widgets/layout/header_widget.dart';
import '../widgets/layout/footer_widget.dart';
import '../widgets/layout/user_drawer.dart';
import '../widgets/common/skeleton_widget.dart';
import '../widgets/common/state_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppHeader(),
      endDrawer: const UserDrawer(),
      body: homeDataAsync.when(
        data: (homeData) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeDataProvider);
            ref.invalidate(categoriesProvider);
          },
          child: Column(
            children: [
              // 下载栏
              AppDownloadBar(siteConfig: homeData.siteConfig),
              
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // 仅监听直接子 ScrollView (SingleChildScrollView) 的滚动事件
                    if (scrollInfo.depth == 0) {
                      final pixels = scrollInfo.metrics.pixels;
                      final maxScroll = scrollInfo.metrics.maxScrollExtent;
                      // debugPrint('Scroll: $pixels / $maxScroll');
                      
                      // 距离底部 200 像素时触发加载更多
                      if (pixels >= maxScroll - 200 && maxScroll > 0) {
                        if (ref.read(scrollBottomProvider) == false) {
                          debugPrint('Reached bottom, triggering load more');
                          ref.read(scrollBottomProvider.notifier).set(true);
                        }
                      } else {
                        if (ref.read(scrollBottomProvider) == true) {
                          ref.read(scrollBottomProvider.notifier).set(false);
                        }
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 轮播图
                      if (homeData.banners != null)
                        HomeBanner(banners: homeData.banners!),
                      
                      const SizedBox(height: 12),
                      
                      // 通知栏
                      if (homeData.notices != null)
                        HomeNotices(notices: homeData.notices!),
                      
                      const SizedBox(height: 12),
                      
                      // 快捷入口
                      const QuickAccess(),
                      
                      const SizedBox(height: 12),
                      
                      // 游戏分类
                      categoriesAsync.when(
                        data: (categories) => GameCategoriesWidget(categories: categories),
                        loading: () => const CategorySkeleton(),
                        error: (err, stack) => ErrorStateWidget(
                          message: '加载分类失败: $err',
                          onRetry: () => ref.invalidate(categoriesProvider),
                        ),
                      ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),
            loading: () => const _HomeLoadingSkeleton(),
            error: (err, stack) => ErrorStateWidget(
          message: '加载页面数据失败: $err',
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Skeleton(height: 50, borderRadius: 0), // AppDownloadBar
          const SizedBox(height: 12),
          const BannerSkeleton(),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Skeleton(height: 40, borderRadius: 20), // Notices
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(child: Skeleton(height: 80, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: Skeleton(height: 80, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: Skeleton(height: 80, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: Skeleton(height: 80, borderRadius: 12)),
              ],
            ), // QuickAccess
          ),
          const SizedBox(height: 12),
          const CategorySkeleton(),
        ],
      ),
    );
  }
}
