import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static const _fontFamilyFallback = <String>[
    'NotoSansSC',
    'Roboto',
    '.AppleSystemUIFont',
    'Arial',
    'sans-serif',
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'NotoSansSC',
      fontFamilyFallback: _fontFamilyFallback,
      textTheme: AppTypography.textTheme.apply(fontFamily: 'NotoSansSC'),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
