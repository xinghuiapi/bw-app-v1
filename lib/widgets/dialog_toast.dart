import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class CustomDialog {
  static void show(
    BuildContext context, {
    String? title,
    required String message,
    String? cancelText,
    String confirmText = 'Confirm',
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    bool showCancelButton = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          backgroundColor: AppColors.surface,
          child: Container(
            width: 320.w,
            padding: EdgeInsets.only(top: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: title != null ? 8.h : 0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  height: 0.5,
                  color: AppColors.border,
                ),
                Row(
                  children: [
                    if (showCancelButton) ...[
                      Expanded(
                        child: _DialogButton(
                          text: cancelText ?? 'Cancel',
                          textColor: AppColors.textPrimary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onCancel != null) onCancel();
                          },
                        ),
                      ),
                      Container(
                        width: 0.5,
                        height: 48.h,
                        color: AppColors.border,
                      ),
                    ],
                    Expanded(
                      child: _DialogButton(
                        text: confirmText,
                        textColor: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onConfirm != null) onConfirm();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final Color textColor;
  final VoidCallback onPressed;
  final FontWeight fontWeight;

  const _DialogButton({
    required this.text,
    required this.textColor,
    required this.onPressed,
    this.fontWeight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 48.h,
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomToast {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.h + MediaQuery.of(context).padding.bottom,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
