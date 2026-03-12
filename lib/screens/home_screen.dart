import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:my_flutter_app/providers/home_provider.dart';
import 'package:my_flutter_app/widgets/home/banner_widget.dart';
import 'package:my_flutter_app/widgets/home/notices_widget.dart';
import 'package:my_flutter_app/widgets/home/quick_access_widget.dart';
import 'package:my_flutter_app/widgets/home/game_categories_widget.dart';
import 'package:my_flutter_app/widgets/home/app_download_bar_widget.dart';
import 'package:my_flutter_app/widgets/layout/header_widget.dart';
import 'package:my_flutter_app/widgets/layout/footer_widget.dart';
import 'package:my_flutter_app/widgets/layout/user_drawer.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/widgets/common/update_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasCheckedUpdate = false;

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    // 监听首页数据加载，完成后检查版本更新
    ref.listen(homeDataProvider, (previous, next) {
      if (!_hasCheckedUpdate && next.hasValue && next.value != null) {
        final siteConfig = next.value!.siteConfig;
        if (siteConfig != null && siteConfig.appVersion != null) {
          _checkVersionUpdate(siteConfig.appVersion!, siteConfig.appDownload);
        }
      }
    });

    return Scaffold(
      appBar: const AppHeader(),
      endDrawer: const UserDrawer(),
      body: homeDataAsync.when(
        data: (homeData) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeDataProvider);
            ref.invalidate(categoriesProvider);
          },
          child: Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // 仅监听直接子 ScrollView (SingleChildScrollView) 的滚动事件
                    if (scrollInfo.depth == 0) {
                      final pixels = scrollInfo.metrics.pixels;
                      final maxScroll = scrollInfo.metrics.maxScrollExtent;
                      
                      // 距离底部 200 像素时触发加载更多
                      if (pixels >= maxScroll - 200 && maxScroll > 0) {
                        if (ref.read(scrollBottomProvider) == false) {
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
                    physics: const AlwaysScrollableScrollPhysics(),
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

  Future<void> _checkVersionUpdate(String serverVersion, String? downloadUrl) async {
    _hasCheckedUpdate = true;
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isVersionGreater(serverVersion, currentVersion)) {
        if (mounted) {
          showUpdateDialog(context, serverVersion, downloadUrl);
        }
      }
    } catch (e) {
      debugPrint('Check version update error: $e');
    }
  }

  bool _isVersionGreater(String serverVersion, String currentVersion) {
    try {
      final serverParts = serverVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();

      final length = serverParts.length > currentParts.length ? serverParts.length : currentParts.length;

      for (var i = 0; i < length; i++) {
        final serverPart = i < serverParts.length ? serverParts[i] : 0;
        final currentPart = i < currentParts.length ? currentParts[i] : 0;

        if (serverPart > currentPart) return true;
        if (serverPart < currentPart) return false;
      }
    } catch (e) {
      debugPrint('Version comparison error: $e');
    }
    return false;
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Skeleton(height: 50, borderRadius: 0), // AppDownloadBar
          SizedBox(height: 12),
          BannerSkeleton(),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Skeleton(height: 40, borderRadius: 20), // Notices
          ),
          SizedBox(height: 12),
          Padding(
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
          SizedBox(height: 12),
          CategorySkeleton(),
        ],
      ),
    );
  }
}
