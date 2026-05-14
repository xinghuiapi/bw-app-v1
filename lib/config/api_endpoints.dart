class ApiEndpoints {
  static const login = '/user/login';
  static const register = '/user/register';
  static const userToken = '/token/user';
  static const userBalance = '/user/balance';
  static const logout = '/token/logout';
  static const changePassword = '/token/repass';
  static const userEdit = '/user/edit';
  static const userPayPassword = '/user/pay_password';
  static const vipList = '/vip/getlist';
  static const captcha = '/captcha/get';
  static const mailCode = '/mail_code/send';
  static const phoneCode = '/phone_code/send';
  static const smsCode = '/code/send';
  static const resetPassword = '/password/get';
  static const telegramLogin = '/telegram/login';
  static const telegramPassword = '/telegram/password';
  static const notifyList = '/notify/getlist';
  static const notifyStatus = '/notify/status';
  static const feedbackList = '/feedback/getlist';
  static const feedbackTypeList = '/feedback_type/getlist';
  static const feedbackSubmit = '/feedback/to';
  static const imageUpload = '/img/save';

  static const interfaceClass = '/interface/class';
  static const interfaceList = '/interface/list';
  static const gameList = '/gamelist/getlist';
  static const gameFavorite = '/user_favorites/game';
  static const systemConfig = '/system/getlist';
  static const interfaceRecommend = '/interface/reco';

  static const activityClass = '/activity/class';
  static const activityList = '/activity/list';
  static const activityDetails = '/activity/details';
  static const activityApply = '/activity/apply';
  static const activityRecord = '/activity/record';

  static const gameLogin = '/game/login';
  static const gameBalance = '/game/balance';
  static const gameAllTrans = '/game/all_trans';
  static const gameDeposit = '/game/deposit';
  static const gameWithdrawal = '/game/withdrawal';
  static const gameTransfer = '/game/transfer';
  static const tradeRecord = '/trade/record';
  static const transferLogList = '/transfers_log/getlist';
  static const moneyLogList = '/money_log/getlist';
  static const depositClass = '/deposit/class';
  static const depositList = '/deposit/getlist';
  static const rechargeOrder = '/recharge/order';
  static const rechargeDetails = '/recharge/details';
  static const rechargeProof = '/recharge/img';
  static const rechargeCancel = '/recharge/cancel';
  static const drawingList = '/drawing/getlist';
  static const drawingOrder = '/drawing/order';
  static const bankList = '/bank/getlist';
  static const memberBankBinding = '/member_bank/binding';
  static const memberBankDelete = '/member_bank/delete';
  static const gameRecordList = '/gamerecord/getlist';
  static const memberFsLogList = '/member_fs_log/getlist';
  static const memberFsLogClaim = '/member_fs_log/claim';
  static const retabeList = '/retabe/list';
  static const retabeAmount = '/retabe/amount';
  static const dayRevenueList = '/day_revenue/getlist';
}

const authIgnoredPaths = <String>{
  ApiEndpoints.login,
  ApiEndpoints.register,
  ApiEndpoints.logout,
  ApiEndpoints.captcha,
  ApiEndpoints.mailCode,
  ApiEndpoints.phoneCode,
  ApiEndpoints.smsCode,
  ApiEndpoints.resetPassword,
  ApiEndpoints.telegramLogin,
  ApiEndpoints.telegramPassword,
  '/token/refresh',
};

const langQueryIgnoredPaths = <String>{
  ApiEndpoints.systemConfig,
};
