import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';

class AppFooter extends ConsumerWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.path;
    final isLoggedIn = ref.watch(authProvider).isLoggedIn;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          border: Border(
            top: BorderSide(
              color: AppTheme.getDividerColor(context),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _getSelectedIndex(location),
          onTap: (index) => _onItemTapped(context, ref, index, isLoggedIn),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.getTertiaryTextColor(context),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: '活动',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.headset_mic), label: '客服'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
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

  void _onItemTapped(
    BuildContext context,
    WidgetRef ref,
    int index,
    bool isLoggedIn,
  ) {
    // 未登录时，点击底部任何导航都跳转登录页
    if (!isLoggedIn) {
      context.push('/login');
      return;
    }

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
