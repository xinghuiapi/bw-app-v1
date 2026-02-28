import 'package:flutter/material.dart';
import '../../models/home_data.dart';
import '../../theme/app_theme.dart';

class AppDownloadBar extends StatefulWidget {
  final SiteConfig? siteConfig;

  const AppDownloadBar({super.key, this.siteConfig});

  @override
  State<AppDownloadBar> createState() => _AppDownloadBarState();
}

class _AppDownloadBarState extends State<AppDownloadBar> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible || widget.siteConfig == null) return const SizedBox.shrink();

    return Container(
      height: 50,
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _visible = false),
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.siteConfig?.title ?? "APP"} APP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '原生流畅体验，更多精彩内容',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // 模拟跳转下载
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('立即下载', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
