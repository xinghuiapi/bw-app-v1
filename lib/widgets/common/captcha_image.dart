import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/auth/auth_models.dart';
import '../../theme/app_colors.dart';

class CaptchaImage extends StatelessWidget {
  const CaptchaImage({super.key, required this.captcha});

  final CaptchaData? captcha;

  @override
  Widget build(BuildContext context) {
    final content = captcha?.imageContent;
    if (content == null || content.isEmpty) return _fallback();

    if (content.startsWith('http://') || content.startsWith('https://')) {
      return Image.network(
        content,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    try {
      final base64String =
          content.contains(',') ? content.split(',').last : content;
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } catch (_) {
      return _fallback();
    }
  }

  Widget _fallback() {
    return Icon(Icons.refresh, color: AppColors.primary, size: 18.sp);
  }
}
