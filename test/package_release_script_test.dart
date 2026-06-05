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

  test('android release command includes generated defines', () {
    final defines = ReleaseDefines.parse(
      '--dart-define=APP_ENV=production '
      '--dart-define=API_BASE_URL=https://example.com/api '
      '--dart-define=ASSET_BASE_URL=https://example.com',
    );

    expect(androidBuildArgs(defines), [
      'build',
      'apk',
      '--release',
      '--split-per-abi',
      '--obfuscate',
      '--split-debug-info=build/app/outputs/symbols',
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

    expect(iosBuildArgs(defines), [
      'build',
      'ios',
      '--release',
      '--no-codesign',
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
