import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_app/providers/home/home_provider.dart';
import 'package:my_flutter_app/providers/auth/auth_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/layout/footer_widget.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';

class CustomerServiceScreen extends ConsumerStatefulWidget {
  const CustomerServiceScreen({super.key});

  @override
  ConsumerState<CustomerServiceScreen> createState() =>
      _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends ConsumerState<CustomerServiceScreen> {
  Future<void> _openCustomerService(BuildContext context, String? link) async {
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('客服链接未配置')));
      return;
    }

    final url = Uri.parse(link);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('无法打开客服链接')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打开链接出错: $e')));
      }
    }
  }

  void _openFeedback(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    if (!authState.isLoggedIn) {
      context.push('/login?redirect=/feedback');
      return;
    }
    context.push('/feedback');
  }

  List<Widget> _buildTgCards(BuildContext context, List<String> links) {
    if (links.isEmpty) return [];

    return List.generate(links.length, (index) {
      final title = links.length == 1 ? 'Telegram客服' : 'Telegram客服${index + 1}';
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _buildServiceCard(
          context,
          icon: Icons.telegram,
          iconColor: Colors.blueAccent,
          title: title,
          description: '点击跳转Telegram在线客服',
          onTap: () => _openCustomerService(context, links[index].trim()),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: const Text('客服与帮助'),
        backgroundColor: AppTheme.getAppBarBackgroundColor(context),
        foregroundColor: AppTheme.getTextPrimary(context),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: homeDataAsync.when(
          data: (homeData) {
            final serviceLink = homeData.siteConfig?.serviceLink;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homeDataProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildServiceCard(
                    context,
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.blue,
                    title: '在线客服',
                    description: '7x24小时全天候为您服务',
                    onTap: () => _openCustomerService(context, serviceLink),
                  ),
                  const SizedBox(height: 16),
                  _buildServiceCard(
                    context,
                    icon: Icons.edit_note,
                    iconColor: Colors.purple,
                    title: '问题反馈',
                    description: '您的建议是我们进步的动力',
                    onTap: () => _openFeedback(context, ref),
                  ),
                  ..._buildTgCards(context, homeData.siteConfig?.tgLinks ?? []),
                ],
              ),
            );
          },
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppTheme.primary),
                const SizedBox(height: 16),
                Text(
                  '正在加载客服信息...',
                  style: TextStyle(
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          error: (err, stack) {
            return ErrorStateWidget(
              message: '加载失败: $err',
              onRetry: () => ref.invalidate(homeDataProvider),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppFooter(),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getDividerColor(context)),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.getTertiaryTextColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
