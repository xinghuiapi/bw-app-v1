import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';

class SearchInput extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final bool autoFocus;

  const SearchInput({
    super.key,
    this.hintText = 'Search',
    this.onChanged,
    this.onSearch,
    this.onClear,
    this.autoFocus = false,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 18.sp,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autoFocus,
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: (_) {
                if (widget.onSearch != null) widget.onSearch!();
              },
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                if (widget.onChanged != null) widget.onChanged!('');
                if (widget.onClear != null) widget.onClear!();
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.cancel,
                  size: 16.sp,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
