import os

expected_pages = [
    "LoginScreen", "RegisterScreen", "ResetPasswordScreen", "TelegramLoginScreen",
    "HomeScreen", "GameScreen", "GameSubListScreen", "ActivityScreen", "ActivityDetailScreen", "ServiceScreen", "MaintenanceScreen",
    "DepositScreen", "DepositOrderDetailScreen", "DepositPaySuccessScreen", "WithdrawScreen", "WithdrawSuccessScreen", "OnlinePayDetailScreen",
    "ProfileScreen", "SettingScreen", "BindPhoneScreen", "BindEmailScreen", "ChangePasswordScreen", "WithdrawPasswordScreen", "RealNameScreen", 
    "MyWalletScreen", "BankCardListScreen", "AddBankCardScreen", "VipScreen", "MessageScreen", "FeedbackScreen", "FeedbackRecordsScreen", "ShareScreen",
    "TransactionRecordScreen", "FundRecordScreen", "ActivityRecordScreen", "GameManagementScreen", "FundManagementScreen"
]

found_pages = set()

for root, dirs, files in os.walk('lib/screens'):
    for file in files:
        if file.endswith('.dart'):
            with open(os.path.join(root, file), 'r', encoding='utf-8') as f:
                content = f.read()
                for page in expected_pages:
                    if page in content:
                        found_pages.add(page)

missing = set(expected_pages) - found_pages
print("Missing pages:", missing)
