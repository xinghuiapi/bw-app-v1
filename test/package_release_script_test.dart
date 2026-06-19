import 'package:flutter_test/flutter_test.dart';

import '../scripts/package_release.dart';

void main() {
  group('ReleaseOptions.parse', () {
    test('reads app name from --name option', () {
      final options = ReleaseOptions.parse([
        '--name',
        'Demo App',
        '--domain',
        'https://example.com',
      ]);

      expect(options.appName, 'Demo App');
      expect(options.defines.apiBaseUrl, 'https://example.com/api');
      expect(options.defines.assetBaseUrl, 'https://example.com');
    });

    test('rejects missing app name', () {
      expect(
        () => ReleaseOptions.parse([]),
        throwsA(
          isA<UsageException>().having(
            (error) => error.message,
            'message',
            contains('--name'),
          ),
        ),
      );
    });

    test('requires release domain', () {
      expect(
        () => ReleaseOptions.parse(['--name', 'Demo App']),
        throwsA(
          isA<UsageException>().having(
            (error) => error.message,
            'message',
            contains('--domain'),
          ),
        ),
      );
    });

    test('normalizes release domain trailing slash', () {
      final options = ReleaseOptions.parse([
        '--name',
        'Demo App',
        '--domain',
        'https://example.com/',
      ]);

      expect(options.defines.apiBaseUrl, 'https://example.com/api');
      expect(options.defines.assetBaseUrl, 'https://example.com');
    });

    test('accepts fixed build version without writing version', () {
      final options = ReleaseOptions.parse([
        '--name',
        'Demo App',
        '--domain',
        'https://example.com',
        '--build-name',
        '1.0.0',
        '--build-number',
        '7',
        '--no-version-write',
      ]);

      expect(options.versionOverride?.displayVersion, '1.0.0.7');
      expect(options.versionOverride?.pubspecValue, '1.0.0+7');
      expect(options.writeVersion, isFalse);
    });

    test('rejects release domain ending with api path', () {
      expect(
        () => ReleaseOptions.parse([
          '--name',
          'Demo App',
          '--domain',
          'https://example.com/api',
        ]),
        throwsA(
          isA<UsageException>().having(
            (error) => error.message,
            'message',
            contains('must not end with /api'),
          ),
        ),
      );
    });
  });

  group('ReleaseDefines', () {
    test('generates production defines from release domain', () {
      final defines = ReleaseDefines.fromDomain('https://example.com');

      expect(defines.appEnv, 'production');
      expect(defines.apiBaseUrl, 'https://example.com/api');
      expect(defines.assetBaseUrl, 'https://example.com');
      expect(defines.asArgs, [
        '--dart-define=APP_ENV=production',
        '--dart-define=API_BASE_URL=https://example.com/api',
        '--dart-define=ASSET_BASE_URL=https://example.com',
      ]);
    });

    test('parses iOS build define output', () {
      final defines = ReleaseDefines.parse(
        '--dart-define=APP_ENV=production '
        '--dart-define=API_BASE_URL=https://example.com/api '
        '--dart-define=ASSET_BASE_URL=https://example.com',
      );

      expect(defines.appEnv, 'production');
      expect(defines.apiBaseUrl, 'https://example.com/api');
      expect(defines.assetBaseUrl, 'https://example.com');
      expect(defines.asArgs, [
        '--dart-define=APP_ENV=production',
        '--dart-define=API_BASE_URL=https://example.com/api',
        '--dart-define=ASSET_BASE_URL=https://example.com',
      ]);
    });

    test('requires API_BASE_URL to end with /api', () {
      final defines = ReleaseDefines.parse(
        '--dart-define=APP_ENV=production '
        '--dart-define=API_BASE_URL=https://example.com '
        '--dart-define=ASSET_BASE_URL=https://example.com',
      );

      expect(
        defines.validate,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('API_BASE_URL'),
          ),
        ),
      );
    });

    test('rejects ASSET_BASE_URL ending with /api', () {
      final defines = ReleaseDefines.parse(
        '--dart-define=APP_ENV=production '
        '--dart-define=API_BASE_URL=https://example.com/api '
        '--dart-define=ASSET_BASE_URL=https://example.com/api',
      );

      expect(
        defines.validate,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('ASSET_BASE_URL'),
          ),
        ),
      );
    });
  });

  group('ReleaseVersion', () {
    test('defines initial release version as 1.0.0.0', () {
      expect(initialReleaseVersion.marketingVersion, '1.0.0');
      expect(initialReleaseVersion.buildNumber, 0);
      expect(initialReleaseVersion.displayVersion, '1.0.0.0');
      expect(initialReleaseVersion.pubspecValue, '1.0.0+0');
    });

    test('parses Flutter pubspec version and exposes four-segment display', () {
      final version = ReleaseVersion.parse('1.0.0+0');

      expect(version.marketingVersion, '1.0.0');
      expect(version.buildNumber, 0);
      expect(version.displayVersion, '1.0.0.0');
      expect(version.pubspecValue, '1.0.0+0');
    });

    test('increments build number only', () {
      final next = ReleaseVersion.parse('1.0.0+0').incrementBuild();

      expect(next.marketingVersion, '1.0.0');
      expect(next.buildNumber, 1);
      expect(next.displayVersion, '1.0.0.1');
      expect(next.pubspecValue, '1.0.0+1');
    });

    test('updates pubspec version line', () {
      final updated = updatePubspecVersion(
        'name: demo\nversion: 1.0.0+0\ndescription: test\n',
        const ReleaseVersion(marketingVersion: '1.0.0', buildNumber: 1),
      );

      expect(updated, contains('version: 1.0.0+1'));
      expect(updated, isNot(contains('version: 1.0.0+0')));
    });
  });

  test('android release command includes generated defines', () {
    final defines = ReleaseDefines.parse(
      '--dart-define=APP_ENV=production '
      '--dart-define=API_BASE_URL=https://example.com/api '
      '--dart-define=ASSET_BASE_URL=https://example.com',
    );
    const version = ReleaseVersion(marketingVersion: '1.0.0', buildNumber: 1);

    expect(androidBuildArgs(defines, version), [
      'build',
      'apk',
      '--release',
      '--split-per-abi',
      '--obfuscate',
      '--split-debug-info=build/app/outputs/symbols',
      '--build-name=1.0.0',
      '--build-number=1',
      '--dart-define=APP_ENV=production',
      '--dart-define=API_BASE_URL=https://example.com/api',
      '--dart-define=ASSET_BASE_URL=https://example.com',
    ]);
  });

  test('iOS release command includes no-codesign and generated defines', () {
    final defines = ReleaseDefines.parse(
      '--dart-define=APP_ENV=production '
      '--dart-define=API_BASE_URL=https://example.com/api '
      '--dart-define=ASSET_BASE_URL=https://example.com',
    );
    const version = ReleaseVersion(marketingVersion: '1.0.0', buildNumber: 1);

    expect(iosBuildArgs(defines, version), [
      'build',
      'ios',
      '--release',
      '--no-codesign',
      '--build-name=1.0.0',
      '--build-number=1',
      '--dart-define=APP_ENV=production',
      '--dart-define=API_BASE_URL=https://example.com/api',
      '--dart-define=ASSET_BASE_URL=https://example.com',
    ]);
  });

  test('iOS command environment includes user gem bin and logger workaround',
      () {
    final environment = iosCommandEnvironment({
      'HOME': '/Users/tester',
      'PATH': '/usr/bin:/bin',
    });

    expect(
      environment['PATH'],
      '/Users/tester/.gem/ruby/2.6.0/bin:/usr/bin:/bin',
    );
    expect(environment['RUBYOPT'], '-rlogger');
  });

  test('unsigned IPA path uses timestamped output directory', () {
    final timestamp = DateTime(2026, 5, 28, 9, 7, 6);

    expect(unsignedIpaDirectoryName(timestamp), 'unsigned-20260528-090706');
    expect(
      unsignedIpaPath(timestamp),
      'build/ios/unsigned-20260528-090706/Runner-unsigned.ipa',
    );
  });
}
