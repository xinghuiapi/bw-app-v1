import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('update_app_name updates iOS display name and Flutter app title',
      () async {
    final tempDir = await Directory.systemTemp.createTemp('app_name_script_');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    await File('${tempDir.path}/android/app/src/main/AndroidManifest.xml')
        .create(recursive: true);
    await File('${tempDir.path}/android/app/src/main/AndroidManifest.xml')
        .writeAsString('''
<manifest>
  <application android:label="Old App Name" />
</manifest>
''');

    await File('${tempDir.path}/ios/Runner/Info.plist').create(recursive: true);
    await File('${tempDir.path}/ios/Runner/Info.plist').writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>CFBundleDisplayName</key>
  <string>Old Ios Name</string>
  <key>CFBundleName</key>
  <string>flutter_ui_project</string>
</dict>
</plist>
''');

    await File('${tempDir.path}/lib/main.dart').create(recursive: true);
    await File('${tempDir.path}/lib/main.dart').writeAsString('''
import 'package:flutter/material.dart';

Widget loadingApp() {
  return MaterialApp(
    title: 'Flutter UI Conversion',
    home: const SizedBox(),
  );
}

Widget readyApp() {
  return MaterialApp.router(
    title: 'Flutter UI Conversion',
    routerConfig: throw UnimplementedError(),
  );
}
''');

    final scriptPath = '${Directory.current.path}/scripts/update_app_name.dart';
    final result = await Process.run(
      'dart',
      [scriptPath, 'Updated App Name'],
      workingDirectory: tempDir.path,
    );

    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(
      await File('${tempDir.path}/ios/Runner/Info.plist').readAsString(),
      contains('<string>Updated App Name</string>'),
    );
    expect(
      await File('${tempDir.path}/lib/main.dart').readAsString(),
      allOf(
        contains("title: 'Updated App Name'"),
        isNot(contains("title: 'Flutter UI Conversion'")),
      ),
    );
  });
}
