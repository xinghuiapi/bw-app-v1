import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_project/widgets/home_user_action_card.dart';

void main() {
  testWidgets('logged-in home action card does not overflow on narrow screens',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: HomeUserActionCard(
                isLoggedIn: true,
                username: 'xhdemo_super_long_username',
                vipText: 'VIP 0',
                symbol: '¥',
                balance: '20000.0000',
                showBalance: true,
                welcomeText: 'Welcome',
                loginText: 'Login',
                registerText: 'Register',
                depositText: 'Deposit',
                withdrawText: 'Withdraw',
                serviceText: 'Support',
                onToggleBalance: () {},
                onRefresh: () {},
                onLogin: () {},
                onRegister: () {},
                onDeposit: () {},
                onWithdraw: () {},
                onService: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
