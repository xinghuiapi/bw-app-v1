import 'dart:io';

/// Script to update the application name across different platforms.
/// It automatically detects the current name from AndroidManifest.xml.
/// Usage: dart run scripts/update_app_name.dart "New App Name"
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/update_app_name.dart "New App Name"');
    exit(1);
  }

  final newName = args[0];
  final androidManifestPath = 'android/app/src/main/AndroidManifest.xml';
  
  // 1. Auto-detect current name from AndroidManifest.xml
  String? currentName;
  final manifestFile = File(androidManifestPath);
  
  if (await manifestFile.exists()) {
    final content = await manifestFile.readAsString();
    final match = RegExp(r'android:label="([^"]+)"').firstMatch(content);
    if (match != null) {
      currentName = match.group(1);
    }
  }

  if (currentName == null) {
    print('❌ Error: Could not detect current app name from $androidManifestPath');
    print('Please ensure android:label is set in your AndroidManifest.xml');
    exit(1);
  }

  if (currentName == newName) {
    print('ℹ️  App name is already "$newName". No changes needed.');
    return;
  }

  final filesToUpdate = [
    androidManifestPath,
    'web/index.html',
    'windows/CMakeLists.txt',
    'macos/Runner/Configs/AppInfo.xcconfig',
    'ios/Runner/Info.plist',
    'assets/translations/zh.i18n.json',
    'assets/translations/en.i18n.json',
    'assets/translations/pt.i18n.json',
  ];

  print('Detected current name: "$currentName"');
  print('Updating app name to: "$newName"...\n');

  for (final filePath in filesToUpdate) {
    final file = File(filePath);
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.contains(currentName)) {
          final updatedContent = content.replaceAll(currentName, newName);
          await file.writeAsString(updatedContent);
          print('✅ Updated: $filePath');
        } else {
          print('⚠️  Skipped (current name not found): $filePath');
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
