import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_ui_project/models/home/home_models.dart';
import 'package:flutter_ui_project/providers/system/system_provider.dart';
import 'package:flutter_ui_project/providers/user/user_provider.dart';
import 'package:flutter_ui_project/screens/main/main_screens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    serviceExternalOpener = defaultServiceExternalOpener;
  });

  testWidgets('service screen renders config_kefu items only', (tester) async {
    final systemProvider = _TestSystemProvider(
      const HomeConfig(
        customerServiceItems: [
          CustomerServiceItem(
            title: '专属客服',
            link: 'https://support.example.com',
            icon: '',
          ),
        ],
        siteConfig: SiteConfig(
          serviceLink: 'https://legacy.example.com',
          tgLink: 'https://t.me/legacy',
        ),
      ),
    );

    await tester.pumpWidget(_wrapApp(systemProvider: systemProvider));
    await tester.pump();

    expect(find.text('专属客服'), findsOneWidget);
    expect(find.text('service.empty'), findsNothing);
    expect(find.text('service.consult'), findsOneWidget);
  });

  testWidgets('service screen shows empty when config_kefu missing', (
    tester,
  ) async {
    final systemProvider = _TestSystemProvider(
      const HomeConfig(
        siteConfig: SiteConfig(
          serviceLink: 'https://legacy.example.com',
          tgLink: 'https://t.me/legacy',
        ),
      ),
    );

    await tester.pumpWidget(_wrapApp(systemProvider: systemProvider));
    await tester.pump();

    expect(find.byType(ServiceScreen), findsOneWidget);
    expect(find.text('service.consult'), findsNothing);
    expect(find.text('service.online'), findsNothing);
  });

  testWidgets('service screen opens t.me links without UrlPolicy blocking', (
    tester,
  ) async {
    final opened = <String>[];
    serviceExternalOpener = (url) async {
      opened.add(url);
      return true;
    };

    final systemProvider = _TestSystemProvider(
      const HomeConfig(
        customerServiceItems: [
          CustomerServiceItem(
            title: 'Telegram客服',
            link: 'https://t.me/KF0591',
            icon: '',
          ),
        ],
      ),
    );

    await tester.pumpWidget(_wrapApp(systemProvider: systemProvider));
    await tester.pump();
    await tester.tap(find.text('Telegram客服'));
    await tester.pump();

    expect(opened, ['https://t.me/KF0591']);
    expect(find.text('service.invalidLink'), findsNothing);
  });
}

Widget _wrapApp({required SystemProvider systemProvider}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, child) => MultiProvider(
      providers: [
        ChangeNotifierProvider<SystemProvider>.value(value: systemProvider),
        ChangeNotifierProvider<UserProvider>(
            create: (_) => _TestUserProvider()),
      ],
      child: const MaterialApp(
        home: ServiceScreen(),
      ),
    ),
  );
}

class _TestSystemProvider extends SystemProvider {
  _TestSystemProvider(HomeConfig config) {
    data = config;
  }

  @override
  Future<void> loadConfig({bool refresh = false}) async {}
}

class _TestUserProvider extends UserProvider {}
