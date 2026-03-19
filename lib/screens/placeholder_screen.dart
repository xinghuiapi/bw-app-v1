import 'package:flutter/material.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
        ),
        backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.getPrimaryTextColor(context)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 64,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              '$title 页面正在开发中...',
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '敬请期待更多功能上线',
              style: TextStyle(
                color: AppTheme.getTertiaryTextColor(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
