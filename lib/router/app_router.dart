import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../providers/record/record_provider.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/system/system_provider.dart';
import '../screens/home_screen.dart';
import '../screens/list_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/telegram_login_screen.dart';
import '../screens/main/main_shell_screen.dart';
import '../screens/main/main_screens.dart';
import '../screens/main/maintenance_screen.dart';
import '../screens/game/game_screen.dart';
import '../screens/game/game_sublist_screen.dart';
import '../screens/game/game_management_screen.dart';
import '../screens/game/game_view_screen.dart';
import '../screens/finance/finance_screens.dart';
import '../screens/finance/fund_management_screen.dart';
import '../screens/finance/my_wallet_screen.dart';
import '../screens/user/user_screens.dart';
import '../screens/search/search_screen.dart';
import 'route_paths.dart';

GoRouter createAppRouter(AuthProvider authProvider,
    {SystemProvider? systemProvider}) {
  final refreshListenable = systemProvider == null
      ? authProvider
      : _RouterRefreshListenable([authProvider, systemProvider]);
  return GoRouter(
    initialLocation: RoutePaths.home,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final location = state.uri.toString();
      final path = state.uri.path;
      final telegramQuery = _telegramQueryFromUri(state.uri);
      if (path != RoutePaths.telegramLogin &&
          _hasTelegramQuery(telegramQuery)) {
        final redirect = _telegramRedirectTarget(state.uri);
        final userId = telegramQuery['user_id'] ?? '';
        final username = telegramQuery['username'] ?? '';
        return '${RoutePaths.telegramLogin}?user_id=${Uri.encodeComponent(userId)}&username=${Uri.encodeComponent(username)}&redirect=${Uri.encodeComponent(redirect)}';
      }

      if (!authProvider.isInitialized) {
        return null;
      }

      final isMaintenance = path == RoutePaths.maintenance;
      final isMaintaining = systemProvider?.config.siteConfig?.status == 0;
      if (isMaintaining && !isMaintenance) {
        return '${RoutePaths.maintenance}?redirect=${Uri.encodeComponent(location)}';
      }
      if (!isMaintaining && isMaintenance) {
        final redirect = state.uri.queryParameters['redirect'];
        if (redirect != null && redirect.isNotEmpty) {
          return Uri.decodeComponent(redirect);
        }
        return RoutePaths.home;
      }
      final isAuthRoute = path == RoutePaths.login ||
          path == RoutePaths.register ||
          path == RoutePaths.resetPassword ||
          path == RoutePaths.telegramLogin;
      final requiresAuth = routeRequiresAuth(path);

      if (!authProvider.isAuthenticated && requiresAuth) {
        return '${RoutePaths.login}?redirect=${Uri.encodeComponent(location)}';
      }

      if (authProvider.isAuthenticated && path == RoutePaths.login) {
        final redirect = state.uri.queryParameters['redirect'];
        if (redirect != null && redirect.isNotEmpty) {
          return Uri.decodeComponent(redirect);
        }
        return RoutePaths.home;
      }

      if (isAuthRoute || requiresAuth) {
        return null;
      }
      return null;
    },
    routes: _routes,
  );
}

bool _hasTelegramQuery(Map<String, String> query) {
  return (query['user_id']?.trim().isNotEmpty ?? false) &&
      (query['username']?.trim().isNotEmpty ?? false);
}

Map<String, String> _telegramQueryFromUri(Uri uri) {
  if (_hasTelegramQuery(uri.queryParameters)) return uri.queryParameters;
  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) return const <String, String>{};
  final parsed =
      Uri.tryParse(fragment.startsWith('/') ? fragment : '/$fragment');
  if (parsed == null) return const <String, String>{};
  return parsed.queryParameters;
}

String _telegramRedirectTarget(Uri uri) {
  final query = _telegramQueryFromUri(uri);
  final cleanQuery = Map<String, String>.from(query)
    ..remove('user_id')
    ..remove('username');
  if (uri.fragment.trim().isNotEmpty &&
      !_hasTelegramQuery(uri.queryParameters)) {
    final fragment = uri.fragment.trim();
    final parsed =
        Uri.tryParse(fragment.startsWith('/') ? fragment : '/$fragment');
    if (parsed != null) {
      return parsed
          .replace(queryParameters: cleanQuery.isEmpty ? null : cleanQuery)
          .toString();
    }
  }
  return uri
      .replace(queryParameters: cleanQuery.isEmpty ? null : cleanQuery)
      .toString();
}

final appRouter = createAppRouter(AuthProvider()..init());

final _routes = <RouteBase>[
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      LoginScreen(redirectPath: state.uri.queryParameters['redirect']),
    ),
  ),
  GoRoute(
    path: '/register',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const RegisterScreen(),
    ),
  ),
  GoRoute(
    path: '/reset-password',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ResetPasswordScreen(),
    ),
  ),
  GoRoute(
    path: '/telegram-login',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const TelegramLoginScreen(),
    ),
  ),
  GoRoute(
    path: '/maintenance',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      MaintenanceScreen(redirectPath: state.uri.queryParameters['redirect']),
    ),
  ),
  GoRoute(
    path: '/list',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ListScreen(),
    ),
  ),
  GoRoute(
    path: '/search',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const SearchScreen(),
    ),
  ),
  StatefulShellRoute.indexedStack(
    pageBuilder: (context, state, navigationShell) => _noTransitionPage(
      state,
      MainShellScreen(navigationShell: navigationShell),
    ),
    branches: [
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const HomeScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/game',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              GameScreen(key: state.pageKey),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/activity',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const ActivityScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/service',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const ServiceScreen(),
            ),
          ),
        ],
      ),
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const ProfileScreen(),
            ),
          ),
        ],
      ),
    ],
  ),
  // Main detail screens
  GoRoute(
    path: '/game-sub',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      GameSubListScreen(
        code: state.uri.queryParameters['code'],
        game: state.uri.queryParameters['game'],
        title: state.uri.queryParameters['title'],
      ),
    ),
  ),
  GoRoute(
    path: '/game/sub',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      GameSubListScreen(
        code: state.uri.queryParameters['code'],
        game: state.uri.queryParameters['game'],
        title: state.uri.queryParameters['title'],
      ),
    ),
  ),
  GoRoute(
    path: '/game-view',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      _buildGameViewScreen(state),
    ),
  ),
  GoRoute(
    path: '/game/play',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      _buildGameViewScreen(state),
    ),
  ),
  GoRoute(
    path: '/activity-detail',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      ActivityDetailScreen(
        id: int.tryParse(state.uri.queryParameters['id'] ?? ''),
      ),
    ),
  ),
  GoRoute(
    path: '/activity/detail/:id',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      ActivityDetailScreen(
        id: int.tryParse(state.pathParameters['id'] ?? ''),
      ),
    ),
  ),
  GoRoute(
    path: '/activity-record',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ActivityRecordScreen(),
    ),
  ),
  GoRoute(
    path: '/activity/records',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ActivityRecordScreen(),
    ),
  ),
  // Finance Screens
  GoRoute(
    path: '/deposit',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const DepositScreen(),
    ),
  ),
  GoRoute(
    path: '/deposit-detail',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      DepositOrderDetailScreen(
        orderId: state.uri.queryParameters['id'],
      ),
    ),
  ),
  GoRoute(
    path: '/deposit/order/:id',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      DepositOrderDetailScreen(
        orderId: state.pathParameters['id'],
      ),
    ),
  ),
  GoRoute(
    path: '/deposit-success',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const DepositPaySuccessScreen(),
    ),
  ),
  GoRoute(
    path: '/deposit/success/:id',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const DepositPaySuccessScreen(),
    ),
  ),
  GoRoute(
    path: '/deposit/failed/:id',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      DepositPayFailedScreen(orderId: state.pathParameters['id']),
    ),
  ),
  GoRoute(
    path: '/withdraw',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const WithdrawScreen(),
    ),
  ),
  GoRoute(
    path: '/withdraw-success',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const WithdrawSuccessScreen(),
    ),
  ),
  GoRoute(
    path: '/withdraw/success',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const WithdrawSuccessScreen(),
    ),
  ),
  GoRoute(
    path: '/online-pay',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      OnlinePayDetailScreen(
        url: _stringExtra(state, 'url'),
        orderId: _stringExtra(state, 'orderId'),
      ),
    ),
  ),
  GoRoute(
    path: '/deposit/online-pay',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      OnlinePayDetailScreen(
        url: _stringExtra(state, 'url'),
        orderId: _stringExtra(state, 'orderId'),
      ),
    ),
  ),
  GoRoute(
    path: '/transaction-records',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      FundManagementScreen(initialTab: _fundRecordTab(state)),
    ),
  ),
  GoRoute(
    path: '/fund-records',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      FundManagementScreen(initialTab: _fundRecordTab(state)),
    ),
  ),
  GoRoute(
    path: '/fund-management',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      FundManagementScreen(initialTab: _fundRecordTab(state)),
    ),
  ),
  GoRoute(
    path: '/fund-manage',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      FundManagementScreen(initialTab: _fundRecordTab(state)),
    ),
  ),
  // User Screens
  GoRoute(
    path: '/setting',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const SettingScreen(),
    ),
  ),
  GoRoute(
    path: '/about-us',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const AboutUsScreen(),
    ),
  ),
  GoRoute(
    path: '/user-profile',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const UserProfileScreen(),
    ),
  ),
  GoRoute(
    path: '/user/UserProfile',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const UserProfileScreen(),
    ),
  ),
  GoRoute(
    path: '/bind-phone',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const BindPhoneScreen(),
    ),
  ),
  GoRoute(
    path: '/user/bind-phone',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const BindPhoneScreen(),
    ),
  ),
  GoRoute(
    path: '/bind-email',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const BindEmailScreen(),
    ),
  ),
  GoRoute(
    path: '/user/bind-email',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const BindEmailScreen(),
    ),
  ),
  GoRoute(
    path: '/change-password',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ChangePasswordScreen(),
    ),
  ),
  GoRoute(
    path: '/user/change-password',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ChangePasswordScreen(),
    ),
  ),
  GoRoute(
    path: '/withdraw-password',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const WithdrawPasswordScreen(),
    ),
  ),
  GoRoute(
    path: '/user/withdrawpassword',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const WithdrawPasswordScreen(),
    ),
  ),
  GoRoute(
    path: '/real-name',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const RealNameScreen(),
    ),
  ),
  GoRoute(
    path: '/user/real-name',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const RealNameScreen(),
    ),
  ),
  GoRoute(
    path: '/my-wallet',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const MyWalletScreen(),
    ),
  ),
  GoRoute(
    path: '/wallet',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const MyWalletScreen(),
    ),
  ),
  GoRoute(
    path: '/cards',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const BankCardListScreen(),
    ),
  ),
  GoRoute(
    path: '/card',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const BankCardListScreen(),
    ),
  ),
  GoRoute(
    path: '/add-card',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const AddBankCardScreen(),
    ),
  ),
  GoRoute(
    path: '/card/add',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const AddBankCardScreen(),
    ),
  ),
  GoRoute(
    path: '/vip',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const VipScreen(),
    ),
  ),
  GoRoute(
    path: '/message',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const MessageScreen(),
    ),
  ),
  GoRoute(
    path: '/feedback',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const FeedbackScreen(),
    ),
  ),
  GoRoute(
    path: '/feedback-records',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const FeedbackRecordsScreen(),
    ),
  ),
  GoRoute(
    path: '/feedback/records',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const FeedbackRecordsScreen(),
    ),
  ),
  GoRoute(
    path: '/share',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const ShareScreen(),
    ),
  ),
  GoRoute(
    path: '/game-management',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const GameManagementScreen(),
    ),
  ),
  GoRoute(
    path: '/game-manage',
    pageBuilder: (context, state) => _noTransitionPage(
      state,
      const GameManagementScreen(),
    ),
  ),
];

NoTransitionPage<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

String? _stringExtra(GoRouterState state, String key) {
  final extra = state.extra;
  if (extra is Map && extra[key] != null) return extra[key].toString();
  return state.uri.queryParameters[key];
}

FundRecordTab _fundRecordTab(GoRouterState state) {
  final tab = state.uri.queryParameters['tab']?.toLowerCase();
  return switch (tab) {
    'withdraw' || 'drawing' || '1' => FundRecordTab.withdraw,
    'transfer' || 'transfers' || '2' => FundRecordTab.transfer,
    'account' || 'bill' || 'money' || '3' => FundRecordTab.account,
    _ => FundRecordTab.deposit,
  };
}

GameViewScreen _buildGameViewScreen(GoRouterState state) {
  final extra = state.extra;
  final data = extra is Map ? extra : const <String, dynamic>{};
  final url = data['url']?.toString() ?? state.uri.queryParameters['url'] ?? '';
  final title = data['title']?.toString() ?? state.uri.queryParameters['title'];
  return GameViewScreen(url: url, title: title);
}

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(this._listenables) {
    for (final listenable in _listenables) {
      listenable.addListener(notifyListeners);
    }
  }

  final List<Listenable> _listenables;

  @override
  void dispose() {
    for (final listenable in _listenables) {
      listenable.removeListener(notifyListeners);
    }
    super.dispose();
  }
}
