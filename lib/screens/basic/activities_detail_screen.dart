import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/providers/activities_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';

class ActivitiesDetailScreen extends ConsumerWidget {
  const ActivitiesDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = GoRouterState.of(context);
    final idStr = state.uri.queryParameters['id'];
    final id = idStr != null ? int.tryParse(idStr) : null;

    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('活动详情')),
        body: const Center(child: Text('无效的活动 ID')),
      );
    }

    final activityAsync = ref.watch(activityDetailProvider(id));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('活动详情'),
        backgroundColor: AppTheme.secondary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: activityAsync.when(
        data: (activity) => _buildContent(context, activity),
        loading: () => const _DetailSkeleton(),
        error: (err, stack) => ErrorStateWidget(
          message: '加载活动详情失败: $err',
          onRetry: () => ref.invalidate(activityDetailProvider(id)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Activity activity) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 活动横幅
          if (activity.img != null)
            WebSafeImage(
              imageUrl: activity.img!,
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  activity.title ?? '',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 时间
                if (activity.startAt != null || activity.endAt != null)
                  Text(
                    '活动时间: ${activity.startAt ?? ''} ~ ${activity.endAt ?? '长期有效'}',
                    style: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                
                const Divider(height: 32, color: Colors.white10),
                
                // 富文本内容
                HtmlWidget(
                  activity.content ?? '',
                  textStyle: const TextStyle(color: AppTheme.textSecondary),
                  onTapUrl: (url) async {
                    // 处理链接跳转
                    return true;
                  },
                ),
                
                const SizedBox(height: 40),
                
                // 立即参与按钮 (如果需要)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // 申请活动逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('立即参与', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Skeleton(height: 200, borderRadius: 0),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 24, width: 200, borderRadius: 12),
                SizedBox(height: 12),
                Skeleton(height: 16, width: 250, borderRadius: 8),
                SizedBox(height: 32),
                Skeleton(height: 200, borderRadius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
