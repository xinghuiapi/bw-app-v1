import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_button.dart';

class AddBankCardScreen extends StatefulWidget {
  const AddBankCardScreen({super.key});

  @override
  State<AddBankCardScreen> createState() => _AddBankCardScreenState();
}

class _AddBankCardScreenState extends State<AddBankCardScreen> {
  final _cardController = TextEditingController();
  final _branchController = TextEditingController();
  final _aliasController = TextEditingController();

  String _selectedType = '银行卡';

  @override
  void dispose() {
    _cardController.dispose();
    _branchController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FA), // Light gray background matching design
      appBar: const CustomNavBar(title: '添加银行卡'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Type Selector ---
              Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
                child: Text(
                  '请选择收款类型',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF5C6573),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildTypeItem('银行卡'),
                  SizedBox(width: 12.w),
                  _buildTypeItem('虚拟币'),
                  SizedBox(width: 12.w),
                  _buildTypeItem('支付宝'),
                ],
              ),
              SizedBox(height: 20.h),

              // --- 2. Form Card ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    _buildFormRow(
                      label: '姓名',
                      child: Text(
                        '请先完成实名',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontSize: 15.sp,
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () => context.push('/real-name'),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '去认证',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildFormRow(
                      label: '开户银行',
                      child: Text(
                        '请选择开户银行',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                          fontSize: 15.sp,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        size: 20.sp,
                      ),
                    ),
                    _buildDivider(),
                    _buildFormRow(
                      label: '银行卡号',
                      child: TextField(
                        controller: _cardController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '请输入银行卡号',
                          hintStyle: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildFormRow(
                      label: '开户支行',
                      child: TextField(
                        controller: _branchController,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '请输入开户支行(选填)',
                          hintStyle: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildFormRow(
                      label: '别名备注',
                      child: TextField(
                        controller: _aliasController,
                        style: TextStyle(
                            fontSize: 15.sp, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '请输入别名备注(选填)',
                          hintStyle: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 15.sp,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // --- 3. Submit Button ---
              CustomButton(
                text: '确认添加',
                onPressed: () {
                  // TODO: Implement logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeItem(String title) {
    final isSelected = _selectedType == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = title;
          });
        },
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F6FF) : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1)
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormRow({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(child: child),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.3),
    );
  }
}
