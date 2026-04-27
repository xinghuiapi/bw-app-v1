import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/models/user/user_models.dart';
import 'package:my_flutter_app/providers/user/notifications_provider.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          ref.read(notificationsProvider.notifier).fetchMessages(refresh: true),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          '站内通知',
          style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
        ),
        backgroundColor: AppTheme.getCardColor(context),
        foregroundColor: AppTheme.getPrimaryTextColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.getPrimaryTextColor(context)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(notificationsProvider.notifier)
            .fetchMessages(refresh: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.messages.isEmpty) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref
            .read(notificationsProvider.notifier)
            .fetchMessages(refresh: true),
      );
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppTheme.getTertiaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无通知',
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == state.messages.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final message = state.messages[index];
        return _buildNotificationCard(message);
      },
    );
  }

  Widget _buildNotificationCard(UserMessage message) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!message.isRead) {
          ref.read(notificationsProvider.notifier).markAsRead(message.id);
        }
        _showNotificationDetail(message);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getDividerColor(context)),
          // Removed BoxShadow for web optimization
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!message.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppTheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Text(
                    message.title ?? '系统通知',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: message.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                  ),
                ),
                Text(
                  message.createdAt ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTertiaryTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _stripHtml(message.content ?? ''),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
  }

  void _showNotificationDetail(UserMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(
          message.title ?? '系统通知',
          style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
        ),
        content: SingleChildScrollView(
          child: HtmlWidget(
            message.content ?? '',
            textStyle: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
