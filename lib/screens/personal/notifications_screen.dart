import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/models/user_models.dart';
import 'package:my_flutter_app/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).fetchMessages(refresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('站内通知'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).fetchMessages(refresh: true),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.textTertiary),
            const SizedBox(height: 16),
            Text(state.error!, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notificationsProvider.notifier).fetchMessages(refresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: AppTheme.textTertiary),
            SizedBox(height: 16),
            Text('暂无通知', style: TextStyle(color: AppTheme.textSecondary)),
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
    return InkWell(
      onTap: () {
        if (!message.isRead) {
          ref.read(notificationsProvider.notifier).markAsRead(message.id);
        }
        _showNotificationDetail(message);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  message.createdAt ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.content ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(UserMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message.title ?? '系统通知'),
        content: SingleChildScrollView(
          child: Text(
            message.content ?? '',
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
