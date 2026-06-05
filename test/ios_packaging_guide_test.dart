import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS packaging cleanup command is safe when unsigned output is absent',
      () async {
    final guide =
        await File('docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md').readAsString();

    expect(guide, contains('build/ios/unsigned-*(N)'));
    expect(guide, isNot(contains('build/ios/unsigned-*\n')));
  });

  test('iOS packaging rename command explains the old-name prompt', () async {
    final guide =
        await File('docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md').readAsString();

    expect(guide, contains('脚本会先读取当前旧名字'));
    expect(guide, contains('Updated app name: "旧名字" -> "新名字"'));
  });

  test('iOS packaging build command includes CocoaPods environment', () async {
    final guide =
        await File('docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md').readAsString();

    expect(guide, contains('PATH="\$HOME/.gem/ruby/2.6.0/bin:\$PATH"'));
    expect(guide, contains('RUBYOPT=-rlogger flutter build ios'));
    expect(guide, contains('--release'));
    expect(guide, contains('--no-codesign'));
  });

  test('iOS packaging build command includes production domain defines',
      () async {
    final guide =
        await File('docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md').readAsString();

    expect(guide, contains('--domain https://你的域名'));
    expect(guide, contains('--dart-define=APP_ENV=production'));
    expect(
        guide, contains('--dart-define=API_BASE_URL=https://example.com/api'));
    expect(guide, contains('--dart-define=ASSET_BASE_URL=https://example.com'));
  });

  test('iOS packaging verification command uses latest unsigned IPA path',
      () async {
    final guide =
        await File('docs/IOS_UNSIGNED_IPA_PACKAGING_GUIDE.md').readAsString();

    expect(
      guide,
      contains(r'OUT_DIR="$(ls -td build/ios/unsigned-* | head -n 1)"'),
    );
    expect(
      guide,
      contains(r'/usr/bin/unzip -l "$OUT_DIR/Runner-unsigned.ipa"'),
    );
    expect(guide, contains(r'ls -lh "$OUT_DIR/Runner-unsigned.ipa"'));
  });
}
