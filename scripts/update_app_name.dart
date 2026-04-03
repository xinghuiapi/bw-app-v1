import 'dart:io';

/// Script to update the application name across different platforms.
/// Usage: dart run scripts/update_app_name.dart "New App Name"
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/update_app_name.dart "New App Name"');
    exit(1);
  }

  final newName = args[0];
  const oldName = '澳门永利';

  final filesToUpdate = [
    'android/app/src/main/AndroidManifest.xml',
    'web/index.html',
    'windows/CMakeLists.txt',
    'macos/Runner/Configs/AppInfo.xcconfig',
    'ios/Runner/Info.plist',
    'assets/translations/zh.i18n.json',
    'assets/translations/en.i18n.json',
    'assets/translations/pt.i18n.json',
  ];

  print('Updating app name from "$oldName" to "$newName"...');

  for (final filePath in filesToUpdate) {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.contains(oldName)) {
          final updatedContent = content.replaceAll(oldName, newName);
          await file.writeAsString(updatedContent);
          print('✅ Updated: $filePath');
        } else {
          print('⚠️  Skipped (old name not found): $filePath');
        }
      } catch (e) {
        print('❌ Error updating $filePath: $e');
      }
    } else {
      print('⚠️  File not found: $filePath');
    }
  }

  print('\nApp name update complete!');
  print('Please run "flutter clean" and rebuild the app for changes to take effect.');
}
