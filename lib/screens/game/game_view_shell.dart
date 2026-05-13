import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/system/system_provider.dart';
import '../../widgets/common/app_network_image.dart';

class GameViewShell extends StatelessWidget {
  const GameViewShell({
    super.key,
    required this.title,
    required this.child,
    this.isLoading = false,
    this.errorText,
    this.onReload,
  });

  final String title;
  final Widget child;
  final bool isLoading;
  final String? errorText;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    final logo = context.watch<SystemProvider>().config.siteConfig?.logo;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _GameHeader(title: title, logo: logo),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(child: child),
                  if (errorText?.trim().isNotEmpty == true)
                    Positioned.fill(
                      child: _GameErrorState(
                        text: errorText!.trim(),
                        onReload: onReload,
                      ),
                    ),
                  if (isLoading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black26,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.title, required this.logo});

  final String title;
  final String? logo;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34.h,
      color: Colors.black.withValues(alpha: 0.9),
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 180.w,
              child: Text(
                title.trim().isNotEmpty ? title.trim() : 'game.title'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (logo?.trim().isNotEmpty == true)
            Center(
              child: AppNetworkImage(
                url: logo,
                width: 88.w,
                height: 28.h,
                fit: BoxFit.contain,
                optimize: false,
                errorWidget: const SizedBox.shrink(),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/game'),
              child: Padding(
                padding: EdgeInsets.only(left: 18.w),
                child: Icon(Icons.close, color: Colors.white, size: 24.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameErrorState extends StatelessWidget {
  const _GameErrorState({required this.text, this.onReload});

  final String text;
  final VoidCallback? onReload;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.white70, size: 42.sp),
              SizedBox(height: 12.h),
              Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              if (onReload != null) ...[
                SizedBox(height: 18.h),
                TextButton(
                  onPressed: onReload,
                  child: Text(
                    'game.reload'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
