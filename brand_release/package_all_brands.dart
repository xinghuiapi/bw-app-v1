import 'dart:io';

import '../scripts/package_release.dart'
    show ReleaseVersion, updatePubspecVersion;

class UsageException implements Exception {
  UsageException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BatchOptions {
  const BatchOptions({
    required this.indexPath,
    required this.outputDirectory,
    required this.brandIds,
    required this.stopOnFailure,
  });

  final String indexPath;
  final String outputDirectory;
  final Set<String> brandIds;
  final bool stopOnFailure;

  static BatchOptions parse(List<String> args) {
    var indexPath = 'brand_release/BRAND_RELEASE_INDEX.md';
    var outputDirectory = 'brand_release/release_artifacts';
    final brandIds = <String>{};
    var stopOnFailure = false;

    for (var i = 0; i < args.length; i += 1) {
      final arg = args[i];
      switch (arg) {
        case '--index':
          indexPath = _readValue(args, i, arg);
          i += 1;
        case '--output':
          outputDirectory = _readValue(args, i, arg);
          i += 1;
        case '--brand':
          brandIds.add(_readValue(args, i, arg));
          i += 1;
        case '--stop-on-failure':
          stopOnFailure = true;
        case '--help':
        case '-h':
          throw UsageException(_usage);
        default:
          throw UsageException('Unknown option: $arg\n\n$_usage');
      }
    }

    return BatchOptions(
      indexPath: indexPath,
      outputDirectory: outputDirectory,
      brandIds: brandIds,
      stopOnFailure: stopOnFailure,
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

    final brand = BrandRelease(
      enabled: enabledText == 'true',
      brandId: cells[1],
      appName: cells[2],
      domain: _normalizeDomain(cells[3]),
      logoPath: cells[4],
    );
    brand.validate(lineNumber);
    return brand;
  }

  void validate(int lineNumber) {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(brandId)) {
      throw StateError(
        'Invalid brand_id at line $lineNumber: $brandId. '
        'Use letters, numbers, underscores, or hyphens.',
      );
    }
    if (appName.isEmpty) {
      throw StateError('app_name must not be empty at line $lineNumber.');
    }
    final uri = Uri.tryParse(domain);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('Invalid domain at line $lineNumber: $domain.');
    }
    if (domain.endsWith('/api')) {
      throw StateError('domain must not end with /api at line $lineNumber.');
    }
    if (!logoPath.toLowerCase().endsWith('.png')) {
      throw StateError('logo_path must be a PNG at line $lineNumber.');
    }
  }

  static String _normalizeDomain(String value) {
    var domain = value.trim();
    while (domain.endsWith('/')) {
      domain = domain.substring(0, domain.length - 1);
    }
    return domain;
  }
}

class BrandResult {
  const BrandResult.success(this.brand, this.outputDir)
      : error = null,
        success = true;

  const BrandResult.failure(this.brand, this.error)
      : outputDir = null,
        success = false;

  final BrandRelease brand;
  final bool success;
  final String? outputDir;
  final Object? error;
}

const _usage = '''
Usage:
  dart run brand_release/package_all_brands.dart [options]

Options:
  --index <path>       Brand index markdown path. Default: brand_release/BRAND_RELEASE_INDEX.md
  --output <path>      Artifact output directory. Default: brand_release/release_artifacts
  --brand <brand_id>   Package only this brand. Can be repeated.
  --stop-on-failure    Stop after the first failed brand.
''';

Future<void> main(List<String> args) async {
  try {
    final options = BatchOptions.parse(args);
    final workflow = BatchReleaseWorkflow(options);
    final results = await workflow.run();
    workflow.printSummary(results);
    if (results.any((result) => !result.success)) {
      exit(1);
    }
  } on UsageException catch (error) {
    stderr.writeln(error.message);
    exit(error.message == _usage ? 0 : 64);
  } on Object catch (error) {
    stderr.writeln(error);
    exit(1);
  }
}

class BatchReleaseWorkflow {
  BatchReleaseWorkflow(this.options);

  final BatchOptions options;

  Future<List<BrandResult>> run() async {
    final brands = await _readBrands();
    final selectedBrands = brands
        .where((brand) => brand.enabled)
        .where(
          (brand) =>
              options.brandIds.isEmpty ||
              options.brandIds.contains(brand.brandId),
        )
        .toList();

    if (selectedBrands.isEmpty) {
      final missingBrands = options.brandIds.difference(
        brands.map((brand) => brand.brandId).toSet(),
      );
      if (missingBrands.isNotEmpty) {
        throw StateError('Unknown brand_id: ${missingBrands.join(', ')}.');
      }
      throw StateError(
        options.brandIds.isEmpty
            ? 'No enabled brands found in ${options.indexPath}.'
            : 'No enabled matching brands found: ${options.brandIds.join(', ')}.',
      );
    }

    final missingBrands = options.brandIds.difference(
      brands.map((brand) => brand.brandId).toSet(),
    );
    if (missingBrands.isNotEmpty) {
      throw StateError('Unknown brand_id: ${missingBrands.join(', ')}.');
    }

    final currentVersion = await _readReleaseVersion();
    final batchVersion = currentVersion.incrementBuild();
    stdout.writeln('Batch release version:');
    stdout.writeln(
      '  current=${currentVersion.displayVersion} (pubspec ${currentVersion.pubspecValue})',
    );
    stdout.writeln(
      '  batch=${batchVersion.displayVersion} (pubspec ${batchVersion.pubspecValue})',
    );

    final results = <BrandResult>[];
    for (final brand in selectedBrands) {
      stdout.writeln('\n========== Packaging ${brand.brandId} ==========');
      try {
        await _packageBrand(brand, batchVersion);
        final outputDir = '${options.outputDirectory}/${brand.brandId}';
        results.add(BrandResult.success(brand, outputDir));
      } on Object catch (error) {
        stderr.writeln('Brand ${brand.brandId} failed: $error');
        results.add(BrandResult.failure(brand, error));
        if (options.stopOnFailure) break;
      }
    }
    if (results.any((result) => result.success)) {
      await _writeReleaseVersion(batchVersion);
    }
    return results;
  }

  Future<List<BrandRelease>> _readBrands() async {
    final file = File(options.indexPath);
    if (!await file.exists()) {
      throw StateError('Brand index not found: ${options.indexPath}');
    }

    final brands = <BrandRelease>[];
    final lines = await file.readAsLines();
    for (var i = 0; i < lines.length; i += 1) {
      final line = lines[i].trim();
      if (!line.startsWith('|') || !line.endsWith('|')) continue;
      if (line.contains('---') || line.contains('brand_id')) continue;
      brands.add(BrandRelease.parseTableRow(line, i + 1));
    }
    return brands;
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

  Future<void> _packageBrand(BrandRelease brand, ReleaseVersion version) async {
    await _prepareLogo(brand);
    await _runStep('Package ${brand.brandId}', 'dart', [
      'run',
      'scripts/package_release.dart',
      '--name',
      brand.appName,
      '--domain',
      brand.domain,
      '--build-name',
      version.marketingVersion,
      '--build-number',
      version.buildNumber.toString(),
      '--no-version-write',
    ]);
    await _copyArtifacts(brand);
  }

  Future<void> _prepareLogo(BrandRelease brand) async {
    final source = File(brand.logoPath);
    if (!await source.exists()) {
      throw StateError(
          'Logo not found for ${brand.brandId}: ${brand.logoPath}');
    }

    final target = File('assets/logo/logo.png');
    await target.parent.create(recursive: true);
    await source.copy(target.path);
    stdout.writeln('Prepared logo: ${brand.logoPath} -> ${target.path}');
  }

  Future<void> _copyArtifacts(BrandRelease brand) async {
    final outputDir = Directory('${options.outputDirectory}/${brand.brandId}');
    await outputDir.create(recursive: true);

    final apk = File('build/app/outputs/flutter-apk/app-arm64-v8a-release.apk');
    if (!await apk.exists()) {
      throw StateError('Expected arm64-v8a APK not found: ${apk.path}');
    }
    final apkTarget = File('${outputDir.path}/${brand.brandId}-v8.apk');
    await apk.copy(apkTarget.path);

    final ipa = await _findLatestUnsignedIpa();
    final ipaTarget = File('${outputDir.path}/${brand.brandId}-unsigned.ipa');
    await ipa.copy(ipaTarget.path);

    stdout.writeln('Copied artifacts:');
    stdout.writeln('  ${apkTarget.path}');
    stdout.writeln('  ${ipaTarget.path}');
  }

  Future<File> _findLatestUnsignedIpa() async {
    final iosBuildDir = Directory('build/ios');
    if (!await iosBuildDir.exists()) {
      throw StateError('iOS build directory not found: ${iosBuildDir.path}');
    }

    final candidates = <File>[];
    await for (final entity in iosBuildDir.list()) {
      if (entity is! Directory) continue;
      if (!_fileName(entity.path).startsWith('unsigned-')) continue;
      final ipa = File('${entity.path}/Runner-unsigned.ipa');
      if (await ipa.exists()) candidates.add(ipa);
    }

    if (candidates.isEmpty) {
      throw StateError('No unsigned IPA found under ${iosBuildDir.path}.');
    }

    candidates.sort((a, b) {
      final aModified = a.lastModifiedSync();
      final bModified = b.lastModifiedSync();
      return bModified.compareTo(aModified);
    });
    return candidates.first;
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final segments =
        normalized.split('/').where((segment) => segment.isNotEmpty);
    return segments.isEmpty ? normalized : segments.last;
  }

  Future<void> _runStep(
    String stepName,
    String executable,
    List<String> arguments,
  ) async {
    stdout.writeln('\n[$stepName] $executable ${arguments.join(' ')}');
    final result = await Process.start(
      executable,
      arguments,
      runInShell: true,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await result.exitCode;
    if (exitCode != 0) {
      throw StateError('$stepName failed with exit code $exitCode.');
    }
  }

  void printSummary(List<BrandResult> results) {
    stdout.writeln('\n========== Batch packaging summary ==========');
    for (final result in results) {
      if (result.success) {
        stdout.writeln(
          '[OK] ${result.brand.brandId}: ${result.outputDir}',
        );
      } else {
        stdout.writeln(
          '[FAILED] ${result.brand.brandId}: ${result.error}',
        );
      }
    }
  }
}
