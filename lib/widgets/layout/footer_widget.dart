import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondary,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _getSelectedIndex(location),
          onTap: (index) => _onItemTapped(context, index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textTertiary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: '活动',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headset_mic),
              label: '客服',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/activities')) return 1;
    if (location.startsWith('/customer-service')) return 2;
    if (location.startsWith('/personal-center')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/activities');
        break;
      case 2:
        context.go('/customer-service');
        break;
      case 3:
        context.go('/personal-center');
        break;
    }
  }
}
