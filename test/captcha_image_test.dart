import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_project/models/auth/auth_models.dart';
import 'package:flutter_ui_project/widgets/common/captcha_image.dart';

void main() {
  testWidgets('captcha data uri renders from memory instead of network',
      (tester) async {
    const transparentPixel =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/p9sAAAAASUVORK5CYII=';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CaptchaImage(
            captcha: CaptchaData(
              captchaKey: 'captcha-key',
              captchaImg: 'data:image/png;base64,$transparentPixel',
            ),
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.image, isA<MemoryImage>());
  });
}
