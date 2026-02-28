import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/home_data.dart';
import '../../providers/activities_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/skeleton_widget.dart';
import '../../widgets/common/state_widgets.dart';
import '../../widgets/common/web_safe_image.dart';
import '../../widgets/layout/footer_widget.dart';
import '../../widgets/layout/header_widget.dart';
import '../../widgets/layout/user_drawer.dart';

class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(activityCategoriesProvider);
    final selectedCategoryId = ref.watch(selectedActivityCategoryIdProvider);
    final activitiesAsync = ref.watch(activityListProvider(selectedCategoryId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppHeader(),
      endDrawer: const UserDrawer(),
      body: SafeArea(
        child: Column(
          children: [
          // 活动分类
          categoriesAsync.when(
            data: (categories) => _buildCategoryTabs(categories, selectedCategoryId),
            loading: () => const _CategoryTabsSkeleton(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
          
          // 活动列表
          Expanded(
            child: activitiesAsync.when(
              data: (activities) {
                if (activities.isEmpty) {
                  return const EmptyStateWidget(message: '暂无活动');
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(activityListProvider(selectedCategoryId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      return _ActivityCard(activity: activity);
                    },
                  ),
                );
              },
              loading: () => const _ActivitiesListSkeleton(),
              error: (err, stack) => ErrorStateWidget(
                message: '加载活动失败: $err',
                onRetry: () => ref.invalidate(activityListProvider(selectedCategoryId)),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: const AppFooter(),
  );
}

  Widget _buildCategoryTabs(List<ActivityClass> categories, int? selectedId) {
    final allCategories = [
      ActivityClass(id: null, title: '全部'),
      ...categories,
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.secondary,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = selectedId == category.id;

          return GestureDetector(
            onTap: () {
              ref.read(selectedActivityCategoryIdProvider.notifier).set(category.id);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                category.title ?? '',
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (activity.id != null) {
          context.push('/activities-detail?id=${activity.id}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 活动图片
            if (activity.img != null)
              WebSafeImage(
                imageUrl: activity.img!,
                height: 160,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: const Icon(Icons.image_not_supported, size: 40, color: AppTheme.textTertiary),
              ),
            
            // 活动标题
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                activity.title ?? '未命名活动',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabsSkeleton extends StatelessWidget {
  const _CategoryTabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: List.generate(4, (index) => const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Skeleton(width: 60, height: 20, borderRadius: 10),
        )),
      ),
    );
  }
}

class _ActivitiesListSkeleton extends StatelessWidget {
  const _ActivitiesListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 220,
          child: const Column(
            children: [
              Skeleton(height: 160, borderRadius: 12),
              SizedBox(height: 12),
              Skeleton(height: 20, width: 200, borderRadius: 10),
            ],
          ),
        );
      },
    );
  }
}
