import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty || args.first.trim().isEmpty) {
    stderr
        .writeln('Usage: dart run scripts/update_app_name.dart "New App Name"');
    exit(64);
  }

  final newName = args.first.trim();
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!await manifest.exists()) {
    stderr.writeln(
        'AndroidManifest.xml not found. Run this script at project root.');
    exit(1);
  }

  final manifestText = await manifest.readAsString();
  final currentName =
      RegExp(r'android:label="([^"]*)"').firstMatch(manifestText)?.group(1);
  if (currentName == null || currentName.isEmpty) {
    stderr.writeln('Could not detect android:label in AndroidManifest.xml.');
    exit(1);
  }

  await _replaceInFile(manifest.path, currentName, newName);
  await _replaceInFile('web/index.html', currentName, newName);
  await _updateWebManifest(newName);

  stdout.writeln('Updated app name: "$currentName" -> "$newName"');
  stdout.writeln('Run flutter clean before the next release build.');
}

Future<void> _replaceInFile(String path, String from, String to) async {
  final file = File(path);
  if (!await file.exists()) return;
  final text = await file.readAsString();
  if (!text.contains(from)) return;
  await file.writeAsString(text.replaceAll(from, to));
  stdout.writeln('Updated $path');
}

Future<void> _updateWebManifest(String name) async {
  final file = File('web/manifest.json');
  if (!await file.exists()) return;
  final json = jsonDecode(await file.readAsString());
  if (json is! Map<String, dynamic>) return;
  json['name'] = name;
  json['short_name'] = name;
  await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  await file.writeAsString('${await file.readAsString()}\n');
  stdout.writeln('Updated ${file.path}');
}
