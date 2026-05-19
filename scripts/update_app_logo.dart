import 'dart:io';

void main(List<String> args) async {
  final sourcePath = args.isEmpty || args.first.trim().isEmpty
      ? 'assets/logo/logo.png'
      : args.first.trim();
  final source = File(sourcePath);
  if (!await source.exists()) {
    stderr.writeln('Logo file not found: ${source.path}');
    stderr.writeln(
        'Put your app launcher logo PNG at assets/logo/logo.png or pass a custom path.');
    stderr.writeln(
        'Usage: dart run scripts/update_app_logo.dart [path/to/logo.png]');
    exit(1);
  }

  final extension = source.uri.pathSegments.last.split('.').last.toLowerCase();
  if (extension != 'png') {
    stderr.writeln('Logo must be a PNG file for flutter_launcher_icons.');
    exit(1);
  }

  final targetDir = Directory('assets/images');
  if (!await targetDir.exists()) {
    await targetDir.create(recursive: true);
  }

  final target = File('assets/images/logo.png');
  await source.copy(target.path);
  stdout.writeln('Copied app launcher logo to ${target.path}');

  final result = await Process.run(
    'dart',
    ['run', 'flutter_launcher_icons'],
    runInShell: true,
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  if (result.exitCode != 0) {
    stderr.writeln(
        'flutter_launcher_icons failed. Run flutter pub get and retry.');
    exit(result.exitCode);
  }

  stdout.writeln('App launcher icons regenerated.');
  stdout.writeln('Splash screen resources were not changed by this script.');
  stdout.writeln(
      'Run flutter clean before release build if the old icon is cached.');
}
