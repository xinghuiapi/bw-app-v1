import os

expected_pages = [
    "LoginScreen", "RegisterScreen", "ResetPasswordScreen", "TelegramLoginScreen",
    "HomeScreen", "GameScreen", "GameSubListScreen", "ActivityScreen", "ActivityDetailScreen", "ServiceScreen",
    "DepositScreen", "DepositOrderDetailScreen", "DepositPaySuccessScreen", "WithdrawScreen", "WithdrawSuccessScreen", "OnlinePayDetailScreen",
    "ProfileScreen", "SettingScreen", "BindPhoneScreen", "BindEmailScreen", "ChangePasswordScreen", "WithdrawPasswordScreen", "RealNameScreen", 
    "MyWalletScreen", "BankCardListScreen", "AddBankCardScreen", "VipScreen", "MessageScreen", "FeedbackScreen", "FeedbackRecordsScreen", "ShareScreen",
    "TransactionRecordScreen", "FundRecordScreen", "ActivityRecordScreen", "GameManagementScreen", "FundManagementScreen"
]

for root, dirs, files in os.walk('lib/screens'):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'rimport os

expected_pages = [
    LoginScreen, R