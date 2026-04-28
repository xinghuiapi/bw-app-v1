import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool showClearButton;

  const CustomTextField({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.showClearButton = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _obscureText = widget.obscureText;

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError
        ? AppColors.danger
        : (_isFocused ? AppColors.primary : AppColors.border);
    final glowColor = hasError
        ? AppColors.danger.withValues(alpha: 0.2)
        : (_isFocused
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.transparent);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: 4.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: widget.prefixIcon!,
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  obscureText: _obscureText,
                  keyboardType: widget.keyboardType,
                  onChanged: widget.onChanged,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
              if (widget.showClearButton &&
                  _controller.text.isNotEmpty &&
                  _isFocused)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    if (widget.onChanged != null) {
                      widget.onChanged!('');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.cancel,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                  ),
                ),
              if (widget.obscureText)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: 12.w, left: widget.showClearButton ? 0 : 8.w),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ),
              if (widget.suffixIcon != null)
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: widget.suffixIcon!,
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }
}
