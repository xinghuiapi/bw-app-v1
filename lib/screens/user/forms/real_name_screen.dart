import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

class RealNameScreen extends StatefulWidget {
  const RealNameScreen({super.key});

  @override
  State<RealNameScreen> createState() => _RealNameScreenState();
}

class _RealNameScreenState extends State<RealNameScreen> {
  final _nameController = TextEditingController();
  final _idCardController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                hintText: '请输入您的真实姓名',
                controller: _nameController,
              ),
              SizedBox(height: 24.h),
              Text(
                '身份证号',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请输入您的身份证号码',
                controller: _idCardController,
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '提交认证',
                onPressed: () {
                  // TODO: Implement real name auth logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
