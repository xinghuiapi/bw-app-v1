import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class HomeNotices extends StatelessWidget {
  final List<NoticeModel> notices;

  const HomeNotices({super.key, required this.notices});

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) return const SizedBox.shrink();

    final String combinedNotices = notices
        .map((n) => n.title ?? '')
        .join('   |   ');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showNoticeList(context),
      child: Container(
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.getInputFillColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.getInputBorderColor(context),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Marquee(
                text: combinedNotices,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.center,
                blankSpace: 100.0,
                velocity: 30.0,
                pauseAfterRound: const Duration(seconds: 1),
                accelerationDuration: const Duration(seconds: 1),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoticeList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: AppTheme.getScaffoldBackgroundColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '公告列表',
                  style: TextStyle(
                    color: AppTheme.getPrimaryTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
            Divider(color: AppTheme.getDividerColor(context)),
            Expanded(
              child: ListView.builder(
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  return ListTile(
                    title: Text(
                      notice.title ?? "无标题",
                      style: TextStyle(
                        color: AppTheme.getPrimaryTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      notice.content ?? "暂无内容",
                      style: TextStyle(
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppTheme.getTertiaryTextColor(context),
                    ),
                    onTap: () => _showNoticeDetail(context, notice),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoticeDetail(BuildContext context, NoticeModel notice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(
          notice.title ?? '公告详情',
          style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
        ),
        content: SingleChildScrollView(
          child: Text(
            notice.content ?? '',
            style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}
