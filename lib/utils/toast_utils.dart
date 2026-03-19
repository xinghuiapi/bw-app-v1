import 'package:flutter/material.dart';

class ToastUtils {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showInfo(String message) {
    _showToast(message, Colors.blue);
  }

  static void showSuccess(String message) {
    _showToast(message, Colors.green);
  }

  static void showWarning(String message) {
    _showToast(message, Colors.orange);
  }

  static void showError(String message) {
    _showToast(message, Colors.red);
  }

  static void _showToast(String message, Color backgroundColor) {
    final messenger = messengerKey.currentState;
    if (messenger != null) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      debugPrint(
        'ToastUtils: ScaffoldMessengerState is null. Message: $message',
      );
    }
  }
}
