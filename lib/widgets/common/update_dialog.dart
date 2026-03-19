import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class UpdateDialog extends StatelessWidget {
  final String version;
  final String? downloadUrl;

  const UpdateDialog({
    super.key,
    required this.version,
    this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 40),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardBackground : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.getDividerColor(context)),
            // Removed BoxShadow for web optimization
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '发现新版本 v$version',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '为了获得更好的使用体验，建议您立即更新到最新版本。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('以后再说'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleUpdate(context),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('立即更新'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 顶部图标装饰
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppTheme.background : Colors.white,
              width: 4,
            ),
          ),
          child: const Icon(
            Icons.system_update,
            color: Colors.white,
            size: 40,
          ),
        ),
      ],
    );
  }

  Future<void> _handleUpdate(BuildContext context) async {
    if (downloadUrl != null && downloadUrl!.isNotEmpty) {
      final url = Uri.parse(downloadUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// 显示更新弹窗的便捷方法
void showUpdateDialog(BuildContext context, String version, String? downloadUrl) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => UpdateDialog(
      version: version,
      downloadUrl: downloadUrl,
    ),
  );
}
