import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../providers/user/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import 'user_form_feedback.dart';

class RealNameScreen extends StatefulWidget {
  const RealNameScreen({super.key});

  @override
  State<RealNameScreen> createState() => _RealNameScreenState();
}

class _RealNameScreenState extends State<RealNameScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProvider>().profile;
    _nameController.text = profile?.realName?.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final isVerified = profile?.hasRealName ?? false;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '实名认证'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.primary, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '为了保障您的资金安全，请完成实名认证。认证信息需与提现银行卡信息一致。',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '认证状态',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isVerified ? '已认证' : '未认证',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isVerified
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                '真实姓名',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: isVerified ? profile!.realName!.trim() : '请输入您的真实姓名',
                controller: _nameController,
                enabled: !isVerified,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: isVerified
                    ? '已完成认证'
                    : provider.isSubmitting
                        ? '提交中...'
                        : '提交认证',
                onPressed: isVerified || provider.isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage('请输入您的真实姓名');
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider.submitRealName(name);
      if (!mounted) return;
      _showMessage('保存成功');
      context.pop();
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, '保存失败'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
