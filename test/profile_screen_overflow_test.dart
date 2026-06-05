import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui_project/models/user/user_models.dart';
import 'package:flutter_ui_project/providers/message/message_provider.dart';
import 'package:flutter_ui_project/providers/user/user_provider.dart';
import 'package:flutter_ui_project/providers/wallet/wallet_provider.dart';
import 'package:flutter_ui_project/screens/user/user_screens.dart';

void main() {
  testWidgets('profile header does not overflow on narrow screens',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final userProvider = _NoopUserProvider()
      ..setData(
        const UserProfile(
          id: 10086,
          username: 'xhdemo_super_long_username',
          nickname: 'xhdemo_super_long_username',
          vipLevel: 'VIP 0',
          balance: '20000.0000',
          symbol: '¥',
        ),
      );
    final messageProvider = _NoopMessageProvider()
      ..setData(const [UserMessage(id: 1, type: 2)]);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<WalletProvider>(
                create: (_) => WalletProvider()),
            ChangeNotifierProvider<MessageProvider>.value(
                value: messageProvider),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

class _NoopUserProvider extends UserProvider {
  @override
  Future<void> loadDayRevenue({bool refresh = false}) async {}
}

class _NoopMessageProvider extends MessageProvider {
  @override
  Future<void> loadMessages({bool refresh = false}) async {}
}
