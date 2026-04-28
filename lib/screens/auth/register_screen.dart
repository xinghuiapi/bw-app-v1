import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF99CEFF),
              Color(0xFFB3D9FA),
              Color(0xFFD1E7FF),
              Color(0xFFE8F3FF),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildRegisterCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          EdgeInsets.only(left: 24.w, right: 24.w, top: 20.h, bottom: 32.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: const Color.fromRGBO(51, 51, 51, 0.85),
                    ),
                  ),
                  const SizedBox(), // Spacer for layout
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                '欢迎注册',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                  letterSpacing: 1.w,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildTag('极速提款'),
                  SizedBox(width: 16.w),
                  _buildTag('数据安全'),
                  SizedBox(width: 16.w),
                  _buildTag('权威认证'),
                ],
              ),
            ],
          ),
          Positioned(
            right: 11.w,
            top: 15.h,
            child: Transform.rotate(
              angle: 15 * 3.1415926535897932 / 180,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFA6CFFF), Color(0xFFD4E8FF)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_add,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 40.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: AppColors.primary, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('账号'),
          _buildInputField(
            controller: _accountController,
            placeholder: '请输入账号',
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel('密码'),
          _buildInputField(
            controller: _passwordController,
            placeholder: '请输入密码',
            obscureText: !_showPassword,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF999999),
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          _buildFieldLabel('确认密码'),
          _buildInputField(
            controller: _confirmPasswordController,
            placeholder: '请确认密码',
            obscureText: !_showConfirmPassword,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _showConfirmPassword = !_showConfirmPassword;
                });
              },
              child: Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Icon(
                  _showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: const Color(0xFF999999),
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
              ).copyWith(
                elevation: WidgetStateProperty.all(4),
              ),
              onPressed: () {
                // Mock register success
                context.go('/');
              },
              child: Text(
                '注 册',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '已有账号？ ',
                    style: TextStyle(
                        fontSize: 14.sp, color: const Color(0xFF999999)),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      '立即登录',
                      style:
                          TextStyle(fontSize: 14.sp, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/'),
                child: Text(
                  '先去逛逛',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF333333),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixWidget,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (prefixWidget != null) prefixWidget,
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFFC0C4CC),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }
}
