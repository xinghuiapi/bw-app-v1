import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

bool isBurmeseLocale(BuildContext context) {
  final code = context.locale.languageCode.toLowerCase();
  return code == 'my';
}

double localizedFontSize(
  BuildContext context,
  double baseSp, {
  double myScale = 0.9,
  double minSp = 10,
}) {
  final value = isBurmeseLocale(context) ? baseSp * myScale : baseSp;
  return value.clamp(minSp, baseSp).sp;
}

class LocalizedOneLineText extends StatelessWidget {
  const LocalizedOneLineText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
    this.myScale = 0.9,
    this.minSp = 10,
    this.overflow = TextOverflow.ellipsis,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final double myScale;
  final double minSp;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final baseSize = style.fontSize ?? 14.sp;
    return Text(
      text,
      maxLines: 1,
      overflow: overflow,
      textAlign: textAlign,
      style: style.copyWith(
        fontSize: localizedFontSize(
          context,
          baseSize / 1.sp,
          myScale: myScale,
          minSp: minSp,
        ),
      ),
    );
  }
}
