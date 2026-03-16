import 'package:flutter/material.dart';

class AppTheme {
  // 品牌色
  static const Color primary = Color(0xFFFF4D4D);
  static const Color secondary = Color(0xFF1E2228);
  
  // 背景色
  static const Color background = Color(0xFF0F1216);
  static const Color cardBackground = Color(0xFF1A1D23);
  static const Color surface = Color(0xFF252930);
  
  // 文本色
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white54;
  static const Color divider = Colors.white10;
  
  // 辅助色
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // 骨架屏颜色
  static const Color skeletonBase = Color(0xFF2A2E35);
  static const Color skeletonHighlight = Color(0xFF3A3E45);

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getDividerColor(BuildContext context) {
    return isDark(context) ? Colors.white10 : Colors.black12;
  }

  static Color getScaffoldBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getAppBarBackgroundColor(BuildContext context) {
    return Theme.of(context).appBarTheme.backgroundColor ?? getScaffoldBackgroundColor(context);
  }

  static Color getPrimaryTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ?? (isDark(context) ? textPrimary : Colors.black87);
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.color ?? (isDark(context) ? textSecondary : Colors.black54);
  }
  
  static Color getTertiaryTextColor(BuildContext context) {
    return isDark(context) ? textTertiary : Colors.black38;
  }

  static Color getInputFillColor(BuildContext context) {
    return isDark(context) ? surface : Colors.white;
  }
  
  static Color getInputBorderColor(BuildContext context) {
    return isDark(context) ? Colors.white.withAlpha(13) : const Color(0xFFE0E0E0);
  }

  static Color getTextPrimary(BuildContext context) => getPrimaryTextColor(context);
  static Color getTextSecondary(BuildContext context) => getSecondaryTextColor(context);
  static Color getTextTertiary(BuildContext context) => getTertiaryTextColor(context);

  static Color getPlaceholderColor(BuildContext context) {
    return isDark(context) ? Colors.white24 : Colors.black26;
  }

  static Color getDisabledColor(BuildContext context) {
    return isDark(context) ? Colors.white10 : const Color(0xFFEEEEEE);
  }

  static Color getDisabledTextColor(BuildContext context) {
    return isDark(context) ? Colors.white38 : const Color(0xFF999999);
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      cardColor: cardBackground,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 0.5,
        space: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      primaryColor: primary,
      cardColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFFE0E0E0),
        surface: Colors.white,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
