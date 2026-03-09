import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/screens/home_screen.dart';
import 'package:my_flutter_app/screens/placeholder_screen.dart';
import 'package:my_flutter_app/screens/auth/login_screen.dart';
import 'package:my_flutter_app/screens/auth/register_screen.dart';
import 'package:my_flutter_app/screens/basic/activities_screen.dart';
import 'package:my_flutter_app/screens/basic/activities_detail_screen.dart';
import 'package:my_flutter_app/screens/basic/games_screen.dart';
import 'package:my_flutter_app/screens/basic/game_view_screen.dart';
import 'package:my_flutter_app/screens/basic/search_screen.dart';
import 'package:my_flutter_app/screens/basic/customer_service_screen.dart';
import 'package:my_flutter_app/screens/basic/about_us_screen.dart';
import 'package:my_flutter_app/screens/basic/feedback_screen.dart';
import 'package:my_flutter_app/screens/basic/password_reset_screen.dart';
import 'package:my_flutter_app/screens/basic/system_maintenance_screen.dart';
import 'package:my_flutter_app/screens/personal/share_invite_screen.dart';
import 'package:my_flutter_app/screens/basic/agent_cooperation_screen.dart';
import 'package:my_flutter_app/screens/personal/personal_center_screen.dart';
import 'package:my_flutter_app/screens/personal/profile_screen.dart';
import 'package:my_flutter_app/screens/personal/profile_edit_screen.dart';
import 'package:my_flutter_app/screens/personal/transaction_records_screen.dart';
import 'package:my_flutter_app/screens/personal/card_packages_screen.dart';
import 'package:my_flutter_app/screens/personal/add_card_package_screen.dart';
import 'package:my_flutter_app/screens/personal/vip_screen.dart';
import 'package:my_flutter_app/screens/personal/bet_records_screen.dart';
import 'package:my_flutter_app/screens/personal/capital_records_screen.dart';
import 'package:my_flutter_app/screens/personal/notifications_screen.dart';
import 'package:my_flutter_app/screens/wallet/recharge_screen.dart';
import 'package:my_flutter_app/screens/wallet/recharge_detail_screen.dart';
import 'package:my_flutter_app/screens/wallet/withdraw_screen.dart';
import 'package:my_flutter_app/screens/wallet/transfer_screen.dart';
import 'package:my_flutter_app/widgets/payment_webview/payment_webview.dart';
import 'package:my_flutter_app/utils/auth_helper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/telegram-login',
        name: 'telegram-login',
        builder: (context, state) => const PlaceholderScreen(title: 'Telegram登录'),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final redirectPath = extra?['redirect'] as String? ?? state.uri.queryParameters['redirect'];
          return LoginScreen(redirectPath: redirectPath);
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/password-reset',
        name: 'password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),
      GoRoute(
        path: '/activities',
        name: 'activities',
        builder: (context, state) => const ActivitiesScreen(),
      ),
      GoRoute(
        path: '/activities-detail',
        name: 'activities-detail',
        builder: (context, state) => const ActivitiesDetailScreen(),
      ),
      
      // 个人中心模块 (需要登录)
      GoRoute(
        path: '/personal-center',
        name: 'personal-center',
        builder: (context, state) => const PersonalCenterScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile',
        name: 'personal-center-profile',
        builder: (context, state) => const ProfileScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-phone',
        name: 'personal-center-profile-phone',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.phone),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-email',
        name: 'personal-center-profile-email',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.email),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-realname',
        name: 'personal-center-profile-realname',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.realName),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-qq',
        name: 'personal-center-profile-qq',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.qq),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-telegram',
        name: 'personal-center-profile-telegram',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.telegram),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-gender',
        name: 'personal-center-profile-gender',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.gender),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-borntime',
        name: 'personal-center-profile-borntime',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.bornTime),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-profile-paypassword',
        name: 'personal-center-profile-paypassword',
        builder: (context, state) => const ProfileEditScreen(type: ProfileEditType.payPassword),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-transaction-records',
        name: 'personal-center-transaction-records',
        builder: (context, state) {
          final index = int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
          return TransactionRecordsScreen(initialIndex: index);
        },
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-capital-records',
        name: 'personal-center-capital-records',
        builder: (context, state) => const CapitalRecordsScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-card-packages',
        name: 'personal-center-card-packages',
        builder: (context, state) => const CardPackagesScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-card-packages-add',
        name: 'personal-center-card-packages-add',
        builder: (context, state) => const AddCardPackageScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-vip',
        name: 'personal-center-vip',
        builder: (context, state) => const VipScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/bet-records',
        name: 'bet-records',
        builder: (context, state) => const BetRecordsScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/personal-center-notifications',
        name: 'personal-center-notifications',
        builder: (context, state) => const NotificationsScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/share-invite',
        name: 'share-invite',
        builder: (context, state) => const ShareInviteScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/agent-cooperation',
        name: 'agent-cooperation',
        builder: (context, state) => const AgentCooperationScreen(),
        redirect: _authGuard,
      ),
      
      // 钱包模块 (需要登录)
      GoRoute(
        path: '/wallet-recharge',
        name: 'wallet-recharge',
        builder: (context, state) => const RechargeScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/wallet-recharge-detail',
        name: 'wallet-recharge-detail',
        builder: (context, state) => const RechargeDetailScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/wallet-withdraw',
        name: 'wallet-withdraw',
        builder: (context, state) => const WithdrawScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/wallet-transfer',
        name: 'wallet-transfer',
        builder: (context, state) => const TransferScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/payment-webview',
        name: 'payment-webview',
        builder: (context, state) {
          final uri = state.uri;
          final url = uri.queryParameters['url'] ?? '';
          final title = uri.queryParameters['title'] ?? '支付';
          return PaymentWebView(url: url, title: title);
        },
        redirect: _authGuard,
      ),
      
      // 游戏模块
      GoRoute(
        path: '/games',
        name: 'games',
        builder: (context, state) => const GamesScreen(),
      ),
      GoRoute(
        path: '/game-view',
        name: 'game-view',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final url = extra?['url'] as String? ?? '';
          final title = extra?['title'] as String?;
          return GameViewScreen(url: url, title: title);
        },
      ),
      GoRoute(
        path: '/customer-service',
        name: 'customer-service',
        builder: (context, state) => const CustomerServiceScreen(),
      ),
      GoRoute(
        path: '/about-us',
        name: 'about-us',
        builder: (context, state) => const AboutUsScreen(),
      ),
      GoRoute(
        path: '/feedback',
        name: 'feedback',
        builder: (context, state) => const FeedbackScreen(),
        redirect: _authGuard,
      ),
      GoRoute(
        path: '/system-maintenance',
        name: 'system-maintenance',
        builder: (context, state) => const SystemMaintenanceScreen(),
      ),
    ],
    
    // 全局重定向或错误处理
    errorBuilder: (context, state) => const PlaceholderScreen(title: '404 Not Found'),
  );

  /// 简单的登录拦截器 (对标 Vue 路由中的 requiresAuth)
  static Future<String?> _authGuard(BuildContext context, GoRouterState state) async {
    final bool loggedIn = await AuthHelper.hasToken();
    if (!loggedIn) {
      // 如果未登录，跳转到登录页，并带上当前路径作为重定向参数
      final location = state.uri.toString();
      return '/login?redirect=$location';
    }
    return null;
  }
}
