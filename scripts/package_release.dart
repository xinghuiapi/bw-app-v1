import 'dart:io';

final _pubspecVersionPattern =
    RegExp(r'^version:\s*(\S+)\s*$', multiLine: true);

const initialReleaseVersion = ReleaseVersion(
  marketingVersion: '1.0.0',
  buildNumber: 0,
);

class UsageException implements Exception {
  UsageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ReleaseOptions {
  const ReleaseOptions({
    required this.appName,
    required this.defines,
    this.versionOverride,
    this.writeVersion = true,
  });

  final String appName;
  final ReleaseDefines defines;
  final ReleaseVersion? versionOverride;
  final bool writeVersion;

  static ReleaseOptions parse(List<String> args) {
    final nameIndex = args.indexOf('--name');
    if (nameIndex == -1 || nameIndex + 1 >= args.length) {
      throw UsageException(
        'Usage: dart run scripts/package_release.dart --name "你的App名字" --domain https://你的域名',
      );
    }
    final domainIndex = args.indexOf('--domain');
    if (domainIndex == -1 || domainIndex + 1 >= args.length) {
      throw UsageException(
        'Usage: dart run scripts/package_release.dart --name "你的App名字" --domain https://你的域名',
      );
    }

    final appName = args[nameIndex + 1].trim();
    if (appName.isEmpty) {
      throw UsageException('--name must not be empty.');
    }
    final domain = args[domainIndex + 1].trim();
    if (domain.isEmpty) {
      throw UsageException('--domain must not be empty.');
    }

    final buildNameIndex = args.indexOf('--build-name');
    final buildNumberIndex = args.indexOf('--build-number');
    ReleaseVersion? versionOverride;
    if (buildNameIndex != -1 || buildNumberIndex != -1) {
      if (buildNameIndex == -1 || buildNameIndex + 1 >= args.length) {
        throw UsageException('--build-name requires a value.');
      }
      if (buildNumberIndex == -1 || buildNumberIndex + 1 >= args.length) {
        throw UsageException('--build-number requires a value.');
      }
      try {
        versionOverride = ReleaseVersion.parse(
          '${args[buildNameIndex + 1]}+${args[buildNumberIndex + 1]}',
        );
      } on StateError catch (error) {
        throw UsageException(error.message);
      }
    }

    try {
      return ReleaseOptions(
        appName: appName,
        defines: ReleaseDefines.fromDomain(domain),
        versionOverride: versionOverride,
        writeVersion: !args.contains('--no-version-write'),
      );
    } on StateError catch (error) {
      throw UsageException(error.message);
    }
  }
}

class ReleaseDefines {
  const ReleaseDefines({
    required this.appEnv,
    required this.apiBaseUrl,
    required this.assetBaseUrl,
  });

  final String appEnv;
  final String apiBaseUrl;
  final String assetBaseUrl;

  List<String> get asArgs => [
        '--dart-define=APP_ENV=$appEnv',
        '--dart-define=API_BASE_URL=$apiBaseUrl',
        '--dart-define=ASSET_BASE_URL=$assetBaseUrl',
      ];

  static ReleaseDefines fromDomain(String domain) {
    var assetBaseUrl = domain.trim();
    while (assetBaseUrl.endsWith('/')) {
      assetBaseUrl = assetBaseUrl.substring(0, assetBaseUrl.length - 1);
    }
    if (assetBaseUrl.isEmpty) {
      throw StateError('--domain must not be empty.');
    }
    if (assetBaseUrl.endsWith('/api')) {
      throw StateError('--domain must not end with /api: $assetBaseUrl');
    }

    final defines = ReleaseDefines(
      appEnv: 'production',
      apiBaseUrl: '$assetBaseUrl/api',
      assetBaseUrl: assetBaseUrl,
    );
    defines.validate();
    return defines;
  }

  static ReleaseDefines parse(String output) {
    final values = <String, String>{};
    for (final token in output.split(RegExp(r'\s+'))) {
      if (!token.startsWith('--dart-define=')) continue;
      final define = token.substring('--dart-define='.length);
      final separatorIndex = define.indexOf('=');
      if (separatorIndex <= 0) continue;
      values[define.substring(0, separatorIndex)] =
          define.substring(separatorIndex + 1);
    }

    final appEnv = values['APP_ENV'];
    final apiBaseUrl = values['API_BASE_URL'];
    final assetBaseUrl = values['ASSET_BASE_URL'];
    if (appEnv == null || apiBaseUrl == null || assetBaseUrl == null) {
      throw StateError(
        'Missing APP_ENV, API_BASE_URL, or ASSET_BASE_URL from iOS build defines.',
      );
    }

    return ReleaseDefines(
      appEnv: appEnv,
      apiBaseUrl: apiBaseUrl,
      assetBaseUrl: assetBaseUrl,
    );
  }

  void validate() {
    if (!apiBaseUrl.endsWith('/api')) {
      throw StateError('API_BASE_URL must end with /api: $apiBaseUrl');
    }
    if (assetBaseUrl.endsWith('/api')) {
      throw StateError('ASSET_BASE_URL must not end with /api: $assetBaseUrl');
    }
  }
}

class ReleaseVersion {
  const ReleaseVersion({
    required this.marketingVersion,
    required this.buildNumber,
  });

  final String marketingVersion;
  final int buildNumber;

  String get displayVersion => '$marketingVersion.$buildNumber';

  String get pubspecValue => '$marketingVersion+$buildNumber';

  ReleaseVersion incrementBuild() => ReleaseVersion(
        marketingVersion: marketingVersion,
        buildNumber: buildNumber + 1,
      );

  static ReleaseVersion parse(String value) {
    final parts = value.trim().split('+');
    if (parts.length != 2) {
      throw StateError(
        'pubspec version must use Flutter format major.minor.patch+build_number: $value',
      );
    }

    final marketingVersion = parts[0].trim();
    final buildNumber = int.tryParse(parts[1].trim());
    if (!RegExp(r'^\d+\.\d+\.\d+$').hasMatch(marketingVersion)) {
      throw StateError(
        'Marketing version must be major.minor.patch, got: $marketingVersion',
      );
    }
    if (buildNumber == null || buildNumber < 0) {
      throw StateError(
        'Build number must be a non-negative integer: ${parts[1]}',
      );
    }

    return ReleaseVersion(
      marketingVersion: marketingVersion,
      buildNumber: buildNumber,
    );
  }

  static ReleaseVersion fromPubspec(String content) {
    final match = _pubspecVersionPattern.firstMatch(content);
    if (match == null) {
      throw StateError('Unable to find version: entry in pubspec.yaml');
    }
    return ReleaseVersion.parse(match.group(1) ?? '');
  }
}

String updatePubspecVersion(String content, ReleaseVersion version) {
  if (!_pubspecVersionPattern.hasMatch(content)) {
    throw StateError('Unable to find version: entry in pubspec.yaml');
  }
  return content.replaceFirst(
    _pubspecVersionPattern,
    'version: ${version.pubspecValue}',
  );
}

List<String> androidBuildArgs(ReleaseDefines defines, ReleaseVersion version) =>
    [
      'build',
      'apk',
      '--release',
      '--split-per-abi',
      '--obfuscate',
      '--split-debug-info=build/app/outputs/symbols',
      '--build-name=${version.marketingVersion}',
      '--build-number=${version.buildNumber}',
      ...defines.asArgs,
    ];

List<String> iosBuildArgs(ReleaseDefines defines, ReleaseVersion version) => [
      'build',
      'ios',
      '--release',
      '--no-codesign',
      '--build-name=${version.marketingVersion}',
      '--build-number=${version.buildNumber}',
      ...defines.asArgs,
    ];

String unsignedIpaDirectoryName(DateTime timestamp) {
  String two(int value) => value.toString().padLeft(2, '0');

  return 'unsigned-'
      '${timestamp.year}'
      '${two(timestamp.month)}'
      '${two(timestamp.day)}-'
      '${two(timestamp.hour)}'
      '${two(timestamp.minute)}'
      '${two(timestamp.second)}';
}

String unsignedIpaPath(DateTime timestamp) =>
    'build/ios/${unsignedIpaDirectoryName(timestamp)}/Runner-unsigned.ipa';

Map<String, String> iosCommandEnvironment([Map<String, String>? base]) {
  final env = Map<String, String>.from(base ?? Platform.environment);
  final gemBin = '${env['HOME'] ?? ''}/.gem/ruby/2.6.0/bin';
  env['PATH'] = '$gemBin:${env['PATH'] ?? ''}';
  env['RUBYOPT'] = '-rlogger';
  return env;
}

Future<void> main(List<String> args) async {
  try {
    final options = ReleaseOptions.parse(args);
    await ReleaseWorkflow(options).run();
  } on UsageException catch (error) {
    stderr.writeln(error.message);
    exit(64);
  } on Object catch (error) {
    stderr.writeln(error);
    exit(1);
  }
}

class ReleaseWorkflow {
  ReleaseWorkflow(this.options);

  final ReleaseOptions options;

  Future<void> run() async {
    await _validateInputs();
    final defines = options.defines;
    final currentVersion = await _readReleaseVersion();
    final buildVersion =
        options.versionOverride ?? currentVersion.incrementBuild();
    _printDefines(defines);
    _printVersion(currentVersion, buildVersion);

    await _runStep('Update launcher logo', 'dart', [
      'run',
      'scripts/update_app_logo.dart',
      'assets/logo/logo.png',
    ]);
    await _runStep('Update app name', 'dart', [
      'run',
      'scripts/update_app_name.dart',
      options.appName,
    ]);
    await _runStep('Flutter clean', 'flutter', ['clean']);
    await _runStep('Flutter pub get', 'flutter', ['pub', 'get']);
    await _runStep(
      'Build Android APKs',
      'flutter',
      androidBuildArgs(defines, buildVersion),
    );
    await _cleanIosOutputs();
    await _runStep(
      'Install iOS Pods',
      'pod',
      ['install'],
      workingDirectory: 'ios',
      environment: iosCommandEnvironment(),
    );
    await _runStep(
      'Build unsigned iOS app',
      'flutter',
      iosBuildArgs(defines, buildVersion),
      environment: iosCommandEnvironment(),
    );

    final ipaPath = await _packageUnsignedIpa(DateTime.now());
    if (options.writeVersion) {
      await _writeReleaseVersion(buildVersion);
    }
    _printArtifacts(ipaPath);
  }

  Future<void> _validateInputs() async {
    final requiredFiles = [
      'assets/logo/logo.png',
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner/Info.plist',
      'pubspec.yaml',
    ];

    for (final path in requiredFiles) {
      if (!await File(path).exists()) {
        throw StateError('Required file not found: $path');
      }
    }
  }

  void _printDefines(ReleaseDefines defines) {
    stdout.writeln('Release defines:');
    stdout.writeln('  APP_ENV=${defines.appEnv}');
    stdout.writeln('  API_BASE_URL=${defines.apiBaseUrl}');
    stdout.writeln('  ASSET_BASE_URL=${defines.assetBaseUrl}');
  }

  void _printVersion(
      ReleaseVersion currentVersion, ReleaseVersion nextVersion) {
    stdout.writeln('Release version:');
    stdout.writeln(
      '  current=${currentVersion.displayVersion} (pubspec ${currentVersion.pubspecValue})',
    );
    stdout.writeln(
      '  next=${nextVersion.displayVersion} (pubspec ${nextVersion.pubspecValue})',
    );
  }

  Future<ReleaseVersion> _readReleaseVersion() async {
    final pubspec = File('pubspec.yaml');
    final content = await pubspec.readAsString();
    return ReleaseVersion.fromPubspec(content);
  }

  Future<void> _writeReleaseVersion(ReleaseVersion version) async {
    final pubspec = File('pubspec.yaml');
    final content = await pubspec.readAsString();
    await pubspec.writeAsString(updatePubspecVersion(content, version));
  }

  Future<void> _cleanIosOutputs() async {
    await _deleteIfExists(Directory('build/ios/iphoneos'));
    await _deleteIfExists(Directory('build/ios/Release-iphoneos'));
    await _deleteIfExists(Directory('build/ios/XCBuildData'));

    final iosBuildDir = Directory('build/ios');
    if (!await iosBuildDir.exists()) return;
    await for (final entity in iosBuildDir.list()) {
      if (entity is Directory &&
          entity.uri.pathSegments.last.startsWith('unsigned-')) {
        await entity.delete(recursive: true);
      }
    }
  }

  Future<String> _packageUnsignedIpa(DateTime timestamp) async {
    final runnerApp = Directory('build/ios/iphoneos/Runner.app');
    if (!await runnerApp.exists()) {
      throw StateError('Runner.app not found: ${runnerApp.path}');
    }

    final outDir =
        Directory('build/ios/${unsignedIpaDirectoryName(timestamp)}');
    final payloadDir = Directory('${outDir.path}/Payload');
    await payloadDir.create(recursive: true);
    await _runStep('Copy Runner.app into Payload', 'cp', [
      '-R',
      runnerApp.path,
      '${payloadDir.path}/',
    ]);
    await _runStep(
      'Create unsigned IPA',
      '/usr/bin/zip',
      ['-qry', 'Runner-unsigned.ipa', 'Payload'],
      workingDirectory: outDir.path,
    );

    final ipaPath = '${outDir.path}/Runner-unsigned.ipa';
    if (!await File(ipaPath).exists()) {
      throw StateError('Unsigned IPA was not created: $ipaPath');
    }
    return ipaPath;
  }

  void _printArtifacts(String ipaPath) {
    final apkPaths = [
      'build/app/outputs/flutter-apk/app-arm64-v8a-release.apk',
      'build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk',
      'build/app/outputs/flutter-apk/app-x86_64-release.apk',
    ];

    stdout.writeln('Release artifacts:');
    stdout.writeln('  Android APK directory: build/app/outputs/flutter-apk');
    for (final path in apkPaths) {
      if (!File(path).existsSync()) {
        throw StateError('Expected Android APK not found: $path');
      }
      stdout.writeln('  $path');
    }
    stdout.writeln('  $ipaPath');
  }

  Future<ProcessResult> _runStep(
    String stepName,
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
  }) async {
    stdout.writeln('\n[$stepName] $executable ${arguments.join(' ')}');
    final result = await Process.run(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      runInShell: true,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      throw StateError('$stepName failed with exit code ${result.exitCode}.');
    }
    return result;
  }

  Future<void> _deleteIfExists(FileSystemEntity entity) async {
    if (await entity.exists()) {
      await entity.delete(recursive: true);
    }
  }
}
