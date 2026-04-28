import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../theme/app_colors.dart';

class CountdownButton extends StatefulWidget {
  final Future<bool> Function() onPressed;
  final int seconds;

  const CountdownButton({
    super.key,
    required this.onPressed,
    this.seconds = 60,
  });

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  int _currentSeconds = 0;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _currentSeconds = widget.seconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _currentSeconds--;
        });
      }
    });
  }

  Future<void> _handlePress() async {
    if (_currentSeconds > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final success = await widget.onPressed();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        _startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _currentSeconds == 0 && !_isLoading;
    final text = _isLoading
        ? '发送中...'
        : (_currentSeconds > 0 ? '重新获取($_currentSeconds)' : '获取验证码');

    return GestureDetector(
      onTap: isActive ? _handlePress : null,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
