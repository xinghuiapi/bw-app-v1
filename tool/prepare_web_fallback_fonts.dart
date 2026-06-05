import 'dart:io';

void main() {
  final project = Directory.current;
  final flutterRoot = _flutterRoot();
  final dataFile = File(
    '${flutterRoot.path}/engine/src/flutter/lib/web_ui/lib/src/engine/font_fallback_data.dart',
  );
  final sourceFont =
      File('${project.path}/assets/fonts/NotoSansSC-Variable.ttf');
  final myanmarFont = File('/System/Library/Fonts/NotoSansMyanmar.ttc');
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
          path.startsWith('notosanssc/') ||
          path.startsWith('notosansmyanmar/') ||
          path.startsWith('notocoloremoji/'))
      .toSet();

  for (final path in paths) {
    final source =
        path.startsWith('notosansmyanmar/') && myanmarFont.existsSync()
            ? myanmarFont
            : sourceFont;
    final target = File('${targetRoot.path}/$path');
    target.parent.createSync(recursive: true);
    final targetType = FileSystemEntity.typeSync(
      target.path,
      followLinks: false,
    );
    if (targetType == FileSystemEntityType.link) {
      final targetLink = Link(target.path);
      if (targetLink.targetSync() == source.path) continue;
      targetLink.deleteSync();
    } else if (target.existsSync()) {
      continue;
    }
    try {
      Link(target.path).createSync(source.path, recursive: true);
    } on FileSystemException {
      source.copySync(target.path);
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
