class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const resetPassword = '/reset-password';
  static const telegramLogin = '/telegram-login';
  static const home = '/';
  static const list = '/list';
  static const search = '/search';
  static const game = '/game';
  static const gameSub = '/game-sub';
  static const activity = '/activity';
  static const activityDetail = '/activity-detail';
  static const activityRecord = '/activity-record';
  static const service = '/service';
  static const deposit = '/deposit';
  static const depositDetail = '/deposit-detail';
  static const depositSuccess = '/deposit-success';
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
  static const bindPhone = '/bind-phone';
  static const bindEmail = '/bind-email';
  static const changePassword = '/change-password';
  static const withdrawPassword = '/withdraw-password';
  static const realName = '/real-name';
  static const myWallet = '/my-wallet';
  static const wallet = '/wallet';
  static const cards = '/cards';
  static const addCard = '/add-card';
  static const vip = '/vip';
  static const message = '/message';
  static const feedback = '/feedback';
  static const feedbackRecords = '/feedback-records';
  static const share = '/share';
  static const gameManagement = '/game-management';
}

const protectedRoutePaths = <String>{
  RoutePaths.deposit,
  RoutePaths.withdraw,
  RoutePaths.transactionRecords,
  RoutePaths.fundRecords,
  RoutePaths.fundManagement,
  RoutePaths.profile,
  RoutePaths.setting,
  RoutePaths.aboutUs,
  RoutePaths.userProfile,
  RoutePaths.bindPhone,
  RoutePaths.bindEmail,
  RoutePaths.changePassword,
  RoutePaths.withdrawPassword,
  RoutePaths.realName,
  RoutePaths.myWallet,
  RoutePaths.wallet,
  RoutePaths.cards,
  RoutePaths.addCard,
  RoutePaths.vip,
  RoutePaths.message,
  RoutePaths.feedback,
  RoutePaths.feedbackRecords,
  RoutePaths.share,
  RoutePaths.gameManagement,
};
