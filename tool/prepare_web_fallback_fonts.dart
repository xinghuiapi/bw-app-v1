import 'dart:io';

void main() {
  final project = Directory.current;
  final flutterRoot = _flutterRoot();
  final dataFile = File(
    '${flutterRoot.path}/engine/src/flutter/lib/web_ui/lib/src/engine/font_fallback_data.dart',
  );
  final sourceFont =
      File('${project.path}/assets/fonts/NotoSansSC-Variable.ttf');
  final targetRoot = Directory('${project.path}/web/assets/fallback_fonts');

  if (!dataFile.existsSync()) {
    stderr.writeln('Missing Flutter fallback font data: ${dataFile.path}');
    exitCode = 1;
    return;
  }
  if (!sourceFont.existsSync()) {
    stderr.writeln('Missing local fallback font: ${sourceFont.path}');
    exitCode = 1;
    return;
  }

  final data = dataFile.readAsStringSync();
  final paths = RegExp(r"'([^']+\.woff2)'")
      .allMatches(data)
      .map((match) => match.group(1)!)
      .where((path) =>
          path.startsWith('notosanssc/') || path.startsWith('notocoloremoji/'))
      .toSet();

  for (final path in paths) {
    final target = File('${targetRoot.path}/$path');
    target.parent.createSync(recursive: true);
    if (target.existsSync()) continue;
    try {
      Link(target.path).createSync(sourceFont.path, recursive: true);
    } on FileSystemException {
      sourceFont.copySync(target.path);
    }
  }

  stdout.writeln('Prepared ${paths.length} local web fallback font files.');
}

Directory _flutterRoot() {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.trim().isNotEmpty) return Directory(env.trim());

  final result = Process.runSync('flutter', ['--version', '--machine']);
  final output = result.stdout.toString();
  final match = RegExp(r'"flutterRoot"\s*:\s*"([^"]+)"').firstMatch(output);
  if (match != null) return Directory(match.group(1)!);

  stderr.writeln('Unable to determine FLUTTER_ROOT.');
  exit(1);
}
