import 'dart:io';

class UsageException implements Exception {
  UsageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class TestOptions {
  const TestOptions({
    required this.brandId,
    required this.deviceId,
    required this.release,
    required this.indexPath,
  });

  final String brandId;
  final String? deviceId;
  final bool release;
  final String indexPath;

  static TestOptions parse(List<String> args) {
    String? brandId;
    String? deviceId;
    var release = true;
    var indexPath = 'brand_release/BRAND_RELEASE_INDEX.md';

    for (var i = 0; i < args.length; i += 1) {
      final arg = args[i];
      switch (arg) {
        case '--brand':
          brandId = _readValue(args, i, arg);
          i += 1;
        case '--device':
          deviceId = _readValue(args, i, arg);
          i += 1;
        case '--index':
          indexPath = _readValue(args, i, arg);
          i += 1;
        case '--debug':
          release = false;
        case '--release':
          release = true;
        case '--help':
        case '-h':
          throw UsageException(_usage);
        default:
          throw UsageException('Unknown option: $arg\n\n$_usage');
      }
    }

    if (brandId == null || brandId.trim().isEmpty) {
      throw UsageException('Missing --brand.\n\n$_usage');
    }

    return TestOptions(
      brandId: brandId,
      deviceId: deviceId,
      release: release,
      indexPath: indexPath,
    );
  }

  static String _readValue(List<String> args, int index, String option) {
    if (index + 1 >= args.length || args[index + 1].startsWith('--')) {
      throw UsageException('Missing value for $option.\n\n$_usage');
    }
    return args[index + 1].trim();
  }
}

class BrandRelease {
  const BrandRelease({
    required this.enabled,
    required this.brandId,
    required this.appName,
    required this.domain,
    required this.logoPath,
  });

  final bool enabled;
  final String brandId;
  final String appName;
  final String domain;
  final String logoPath;

  String get apiBaseUrl => '$domain/api';
  String get assetBaseUrl => domain;

  static BrandRelease parseTableRow(String line, int lineNumber) {
    final cells = line
        .trim()
        .substring(1, line.trim().length - 1)
        .split('|')
        .map((cell) => cell.trim())
        .toList();

    if (cells.length != 5) {
      throw StateError(
        'Invalid brand index row at line $lineNumber: expected 5 columns.',
      );
    }

    final enabledText = cells[0].toLowerCase();
    if (enabledText != 'true' && enabledText != 'false') {
      throw StateError(
        'Invalid enabled value at line $lineNumber: ${cells[0]}.',
      );
    }

    var domain = cells[3];
    while (domain.endsWith('/')) {
      domain = domain.substring(0, domain.length - 1);
    }
    if (domain.endsWith('/api')) {
      throw StateError('domain must not end with /api at line $lineNumber.');
    }

    return BrandRelease(
      enabled: enabledText == 'true',
      brandId: cells[1],
      appName: cells[2],
      domain: domain,
      logoPath: cells[4],
    );
  }
}

const _usage = '''
Usage:
  dart run brand_release/test_brand_on_iphone.dart --brand <brand_id> [--device <iphone_device_id>] [--release|--debug]

Examples:
  dart run brand_release/test_brand_on_iphone.dart --brand xuyl
  dart run brand_release/test_brand_on_iphone.dart --brand xuyl --device 00008030-001479602198802E

This command reads brand_release/BRAND_RELEASE_INDEX.md, applies the brand logo/name,
then runs the app on the connected iPhone with the brand domain dart-defines.
It does not install the unsigned IPA.
''';

Future<void> main(List<String> args) async {
  try {
    final options = TestOptions.parse(args);
    await BrandIphoneTestWorkflow(options).run();
  } on UsageException catch (error) {
    stderr.writeln(error.message);
    exit(error.message == _usage ? 0 : 64);
  } on Object catch (error) {
    stderr.writeln(error);
    exit(1);
  }
}

class BrandIphoneTestWorkflow {
  BrandIphoneTestWorkflow(this.options);

  final TestOptions options;

  Future<void> run() async {
    if (!Platform.isMacOS) {
      throw StateError('iPhone testing requires macOS.');
    }

    final brand = await _readBrand();
    if (!brand.enabled) {
      throw StateError(
        'Brand is disabled in ${options.indexPath}: ${brand.brandId}',
      );
    }

    await _prepareBrand(brand);
    final device = options.deviceId ?? await _detectIphoneDevice();
    _printRunConfig(brand, device);
    await _runFlutter(brand, device);
  }

  Future<BrandRelease> _readBrand() async {
    final file = File(options.indexPath);
    if (!await file.exists()) {
      throw StateError('Brand index not found: ${options.indexPath}');
    }

    final lines = await file.readAsLines();
    for (var i = 0; i < lines.length; i += 1) {
      final line = lines[i].trim();
      if (!line.startsWith('|') || !line.endsWith('|')) continue;
      if (line.contains('---') || line.contains('brand_id')) continue;
      final brand = BrandRelease.parseTableRow(line, i + 1);
      if (brand.brandId == options.brandId) return brand;
    }
    throw StateError(
      'Brand not found in ${options.indexPath}: ${options.brandId}',
    );
  }

  Future<void> _prepareBrand(BrandRelease brand) async {
    final logo = File(brand.logoPath);
    if (!await logo.exists()) {
      throw StateError('Logo not found: ${brand.logoPath}');
    }

    await logo.copy('assets/logo/logo.png');
    await _runStep('Update launcher logo', 'dart', [
      'run',
      'scripts/update_app_logo.dart',
      'assets/logo/logo.png',
    ]);
    await _runStep('Update app name', 'dart', [
      'run',
      'scripts/update_app_name.dart',
      brand.appName,
    ]);
    await _runStep('Flutter pub get', 'flutter', ['pub', 'get']);
  }

  Future<String> _detectIphoneDevice() async {
    final result = await _runStep('Detect Flutter devices', 'flutter', [
      'devices',
    ]);

    final devices = <String>[];
    for (final line in result.stdout.toString().split('\n')) {
      if (!line.contains('ios') || !line.contains('mobile')) continue;
      final parts = line.split('•').map((part) => part.trim()).toList();
      if (parts.length >= 2 && parts[1].isNotEmpty) {
        devices.add(parts[1]);
      }
    }

    if (devices.isEmpty) {
      throw StateError(
        'No iPhone device found. Connect the iPhone and run flutter devices.',
      );
    }
    if (devices.length > 1) {
      throw StateError(
        'Multiple iPhone devices found. Pass --device with one id:\n'
        '${devices.map((device) => '  $device').join('\n')}',
      );
    }
    return devices.single;
  }

  void _printRunConfig(BrandRelease brand, String device) {
    stdout.writeln('\nBrand iPhone test config:');
    stdout.writeln('  brand_id=${brand.brandId}');
    stdout.writeln('  app_name=${brand.appName}');
    stdout.writeln('  device=$device');
    stdout.writeln('  mode=${options.release ? 'release' : 'debug'}');
    stdout.writeln('  APP_ENV=production');
    stdout.writeln('  API_BASE_URL=${brand.apiBaseUrl}');
    stdout.writeln('  ASSET_BASE_URL=${brand.assetBaseUrl}');
  }

  Future<void> _runFlutter(BrandRelease brand, String device) async {
    final args = [
      'run',
      '-d',
      device,
      if (options.release) '--release',
      '--dart-define=APP_ENV=production',
      '--dart-define=API_BASE_URL=${brand.apiBaseUrl}',
      '--dart-define=ASSET_BASE_URL=${brand.assetBaseUrl}',
    ];
    await _runStreamingStep('Run on iPhone', 'flutter', args);
  }

  Future<ProcessResult> _runStep(
    String stepName,
    String executable,
    List<String> arguments,
  ) async {
    stdout.writeln('\n[$stepName] $executable ${arguments.join(' ')}');
    final result = await Process.run(
      executable,
      arguments,
      runInShell: true,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      throw StateError('$stepName failed with exit code ${result.exitCode}.');
    }
    return result;
  }

  Future<void> _runStreamingStep(
    String stepName,
    String executable,
    List<String> arguments,
  ) async {
    stdout.writeln('\n[$stepName] $executable ${arguments.join(' ')}');
    final process = await Process.start(
      executable,
      arguments,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw StateError('$stepName failed with exit code $exitCode.');
    }
  }
}
