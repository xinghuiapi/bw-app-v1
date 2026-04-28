import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import 'dart:async';

class NoticeBar extends StatefulWidget {
  final String text;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final VoidCallback? onRightIconTap;
  final VoidCallback? onTap;
  final Color? color;
  final Color? backgroundColor;

  const NoticeBar({
    super.key,
    required this.text,
    this.leftIcon,
    this.rightIcon,
    this.onRightIconTap,
    this.onTap,
    this.color,
    this.backgroundColor,
  });

  @override
  State<NoticeBar> createState() => _NoticeBarState();
}

class _NoticeBarState extends State<NoticeBar>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolling = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartScrolling();
    });
  }

  void _checkAndStartScrolling() {
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      _startScrolling();
    }
  }

  void _startScrolling() {
    if (_isScrolling) return;
    _isScrolling = true;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_scrollController.hasClients) return;

      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.offset;

      if (currentScroll >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 1.0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.color ?? AppColors.warning;
    final bgColor =
        widget.backgroundColor ?? AppColors.warning.withValues(alpha: 0.1);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        color: bgColor,
        child: Row(
          children: [
            if (widget.leftIcon != null)
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconTheme(
                  data: IconThemeData(color: textColor, size: 16.sp),
                  child: widget.leftIcon!,
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
            if (widget.rightIcon != null)
              GestureDetector(
                onTap: widget.onRightIconTap,
                child: Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: IconTheme(
                    data: IconThemeData(color: textColor, size: 16.sp),
                    child: widget.rightIcon!,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
