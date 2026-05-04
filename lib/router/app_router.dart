import 'package:go_router/go_router.dart';
import '../providers/auth/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/list_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/telegram_login_screen.dart';
import '../screens/main/main_screens.dart';
import '../screens/game/game_screen.dart';
import '../screens/game/game_sublist_screen.dart';
import '../screens/game/game_management_screen.dart';
import '../screens/finance/finance_screens.dart';
import '../screens/finance/fund_management_screen.dart';
import '../screens/finance/my_wallet_screen.dart';
import '../screens/user/user_screens.dart';
import '../screens/search/search_screen.dart';
import 'route_paths.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: RoutePaths.login,
    refreshListenable: authProvider,
    redirect: (context, state) {
      if (!authProvider.isInitialized) {
        return null;
      }

      final location = state.uri.toString();
      final path = state.uri.path;
      final isAuthRoute = path == RoutePaths.login ||
          path == RoutePaths.register ||
          path == RoutePaths.resetPassword ||
          path == RoutePaths.telegramLogin;
      final requiresAuth = protectedRoutePaths.contains(path);

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

final appRouter = createAppRouter(AuthProvider()..init());

final _routes = <RouteBase>[
  GoRoute(
    path: '/login',
    builder: (context, state) => LoginScreen(
      redirectPath: state.uri.queryParameters['redirect'],
    ),
  ),
  GoRoute(
    path: '/register',
    builder: (context, state) => const RegisterScreen(),
  ),
  GoRoute(
    path: '/reset-password',
    builder: (context, state) => const ResetPasswordScreen(),
  ),
  GoRoute(
    path: '/telegram-login',
    builder: (context, state) => const TelegramLoginScreen(),
  ),
  GoRoute(
    path: '/',
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: '/list',
    builder: (context, state) => const ListScreen(),
  ),
  GoRoute(
    path: '/search',
    builder: (context, state) => const SearchScreen(),
  ),
  // Main Screens
  GoRoute(
    path: '/game',
    builder: (context, state) => GameScreen(key: state.pageKey),
  ),
  GoRoute(
      path: '/game-sub',
      builder: (context, state) => GameSubListScreen(
            code: state.uri.queryParameters['code'],
            game: state.uri.queryParameters['game'],
            title: state.uri.queryParameters['title'],
          )),
  GoRoute(
      path: '/activity', builder: (context, state) => const ActivityScreen()),
  GoRoute(
      path: '/activity-detail',
      builder: (context, state) => const ActivityDetailScreen()),
  GoRoute(
      path: '/activity-record',
      builder: (context, state) => const ActivityRecordScreen()),
  GoRoute(path: '/service', builder: (context, state) => const ServiceScreen()),
  // Finance Screens
  GoRoute(path: '/deposit', builder: (context, state) => const DepositScreen()),
  GoRoute(
      path: '/deposit-detail',
      builder: (context, state) => const DepositOrderDetailScreen()),
  GoRoute(
      path: '/deposit-success',
      builder: (context, state) => const DepositPaySuccessScreen()),
  GoRoute(
      path: '/withdraw', builder: (context, state) => const WithdrawScreen()),
  GoRoute(
      path: '/withdraw-success',
      builder: (context, state) => const WithdrawSuccessScreen()),
  GoRoute(
      path: '/online-pay',
      builder: (context, state) => const OnlinePayDetailScreen()),
  GoRoute(
      path: '/transaction-records',
      builder: (context, state) => const TransactionRecordScreen()),
  GoRoute(
      path: '/fund-records',
      builder: (context, state) => const FundRecordScreen()),
  GoRoute(
      path: '/fund-management',
      builder: (context, state) => const FundManagementScreen()),
  // User Screens
  GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
  GoRoute(path: '/setting', builder: (context, state) => const SettingScreen()),
  GoRoute(
      path: '/bind-phone',
      builder: (context, state) => const BindPhoneScreen()),
  GoRoute(
      path: '/bind-email',
      builder: (context, state) => const BindEmailScreen()),
  GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen()),
  GoRoute(
      path: '/withdraw-password',
      builder: (context, state) => const WithdrawPasswordScreen()),
  GoRoute(
      path: '/real-name', builder: (context, state) => const RealNameScreen()),
  GoRoute(
      path: '/my-wallet', builder: (context, state) => const MyWalletScreen()),
  GoRoute(
      path: '/wallet',
      builder: (context, state) => const FundManagementScreen()),
  GoRoute(
      path: '/cards', builder: (context, state) => const BankCardListScreen()),
  GoRoute(
      path: '/add-card',
      builder: (context, state) => const AddBankCardScreen()),
  GoRoute(path: '/vip', builder: (context, state) => const VipScreen()),
  GoRoute(path: '/message', builder: (context, state) => const MessageScreen()),
  GoRoute(
      path: '/feedback', builder: (context, state) => const FeedbackScreen()),
  GoRoute(
      path: '/feedback-records',
      builder: (context, state) => const FeedbackRecordsScreen()),
  GoRoute(path: '/share', builder: (context, state) => const ShareScreen()),
  GoRoute(
      path: '/game-management',
      builder: (context, state) => const GameManagementScreen()),
];
