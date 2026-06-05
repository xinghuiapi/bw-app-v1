class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const telegramLogin = '/telegram-login';
  static const maintenance = '/maintenance';
  static const home = '/';
  static const list = '/list';
  static const search = '/search';
  static const game = '/game';
  static const gameSub = '/game-sub';
  static const gameSubM1 = '/game/sub';
  static const gameView = '/game-view';
  static const gamePlayM1 = '/game/play';
  static const activity = '/activity';
  static const activityDetail = '/activity-detail';
  static const activityRecordsM1 = '/activity/records';
  static const activityRecord = '/activity-record';
  static const service = '/service';
  static const deposit = '/deposit';
  static const depositDetail = '/deposit-detail';
  static const depositSuccess = '/deposit-success';
  static const depositOnlinePayM1 = '/deposit/online-pay';
  static const withdraw = '/withdraw';
  static const withdrawSuccess = '/withdraw-success';
  static const onlinePay = '/online-pay';
  static const transactionRecords = '/transaction-records';
  static const fundRecords = '/fund-records';
  static const fundManagement = '/fund-management';
  static const profile = '/profile';
  static const setting = '/setting';
  static const aboutUs = '/about-us';
  static const userProfile = '/user-profile';
  static const userProfileM1 = '/user/UserProfile';
  static const realNameM1 = '/user/real-name';
  static const withdrawPasswordM1 = '/user/withdrawpassword';
  static const changePasswordM1 = '/user/change-password';
  static const bindPhoneM1 = '/user/bind-phone';
  static const bindEmailM1 = '/user/bind-email';
  static const bindPhone = '/bind-phone';
  static const bindEmail = '/bind-email';
  static const changePassword = '/change-password';
  static const withdrawPassword = '/withdraw-password';
  static const realName = '/real-name';
  static const redemptionCode = '/redemption-code';
  static const income = '/income';
  static const team = '/team';
  static const fyLevel = '/fy-level';
  static const myWallet = '/my-wallet';
  static const wallet = '/wallet';
  static const cards = '/cards';
  static const cardListM1 = '/card';
  static const addCard = '/add-card';
  static const addCardM1 = '/card/add';
  static const vip = '/vip';
  static const message = '/message';
  static const feedback = '/feedback';
  static const feedbackRecords = '/feedback-records';
  static const feedbackRecordsM1 = '/feedback/records';
  static const share = '/share';
  static const gameManagement = '/game-management';
  static const gameManageM1 = '/game-manage';
  static const fundManageM1 = '/fund-manage';
}

const protectedRoutePaths = <String>{
  RoutePaths.gameSub,
  RoutePaths.gameSubM1,
  RoutePaths.gamePlayM1,
  RoutePaths.activityDetail,
  RoutePaths.activityRecord,
  RoutePaths.activityRecordsM1,
  RoutePaths.deposit,
  RoutePaths.depositDetail,
  RoutePaths.depositSuccess,
  RoutePaths.depositOnlinePayM1,
  RoutePaths.withdraw,
  RoutePaths.withdrawSuccess,
  RoutePaths.onlinePay,
  RoutePaths.transactionRecords,
  RoutePaths.fundRecords,
  RoutePaths.fundManagement,
  RoutePaths.fundManageM1,
  RoutePaths.profile,
  RoutePaths.setting,
  RoutePaths.aboutUs,
  RoutePaths.userProfile,
  RoutePaths.userProfileM1,
  RoutePaths.realNameM1,
  RoutePaths.withdrawPasswordM1,
  RoutePaths.changePasswordM1,
  RoutePaths.bindPhoneM1,
  RoutePaths.bindEmailM1,
  RoutePaths.bindPhone,
  RoutePaths.bindEmail,
  RoutePaths.changePassword,
  RoutePaths.withdrawPassword,
  RoutePaths.realName,
  RoutePaths.redemptionCode,
  RoutePaths.income,
  RoutePaths.team,
  RoutePaths.fyLevel,
  RoutePaths.myWallet,
  RoutePaths.wallet,
  RoutePaths.cards,
  RoutePaths.cardListM1,
  RoutePaths.addCard,
  RoutePaths.addCardM1,
  RoutePaths.vip,
  RoutePaths.message,
  RoutePaths.feedback,
  RoutePaths.feedbackRecords,
  RoutePaths.feedbackRecordsM1,
  RoutePaths.share,
  RoutePaths.gameManagement,
  RoutePaths.gameManageM1,
  RoutePaths.gameView,
};

const protectedRoutePrefixes = <String>{
  '/activity/detail/',
  '/deposit/order/',
  '/deposit/success/',
  '/deposit/failed/',
};

bool routeRequiresAuth(String path) {
  if (protectedRoutePaths.contains(path)) return true;
  return protectedRoutePrefixes.any(path.startsWith);
}
