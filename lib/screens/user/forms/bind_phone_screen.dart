import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/countdown_button.dart';

class BindPhoneScreen extends StatefulWidget {
  const BindPhoneScreen({super.key});

  @override
  State<BindPhoneScreen> createState() => _BindPhoneScreenState();
}

class _BindPhoneScreenState extends State<BindPhoneScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomNavBar(title: '绑定手机号'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '手机号',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请输入手机号码',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 24.h),
              Text(
                '验证码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              CustomTextField(
                hintText: '请输入验证码',
                controller: _codeController,
                keyboardType: TextInputType.number,
                suffixIcon: CountdownButton(
                  onPressed: () async {
                    // TODO: Implement send code logic
                    await Future.delayed(const Duration(seconds: 1));
                    return true; // Return true to start countdown
                  },
                ),
              ),
              SizedBox(height: 48.h),
              CustomButton(
                text: '确认绑定',
                onPressed: () {
                  // TODO: Implement bind phone logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
