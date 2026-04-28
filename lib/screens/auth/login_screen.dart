import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();

  bool _showPassword = false;
  String _activeTab = 'username'; // 'username' or 'phone'
  String _selectedCountryCode = '+86';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
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
                _buildLoginCard(),
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
                  const SizedBox(), // Spacer for layout
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Icon(
                      Icons.close,
                      size: 22.sp,
                      color: const Color.fromRGBO(51, 51, 51, 0.85),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                '欢迎回来',
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
                    Icons.favorite,
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

  Widget _buildLoginCard() {
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
          _buildTabs(),
          SizedBox(height: 30.h),
          if (_activeTab == 'username')
            _buildUsernameForm()
          else
            _buildPhoneForm(),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '忘记密码？ ',
                style:
                    TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
              ),
              GestureDetector(
                onTap: () => context.push('/reset-password'),
                child: Text(
                  '重置',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
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
                // Mock login success
                context.go('/');
              },
              child: Text(
                '登录',
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
                    '还没有账号？ ',
                    style: TextStyle(
                        fontSize: 14.sp, color: const Color(0xFF999999)),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text(
                      '立即注册',
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

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTabItem('username', '账号登录'),
        SizedBox(width: 32.w),
        _buildTabItem('phone', '手机号登录'),
      ],
    );
  }

  Widget _buildTabItem(String tabValue, String title) {
    final isActive = _activeTab == tabValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = tabValue;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isActive ? 18.sp : 16.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color:
                  isActive ? const Color(0xFF333333) : const Color(0xFF999999),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('账号'),
        _buildInputField(
          controller: _usernameController,
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
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('手机号'),
        _buildInputField(
          controller: _phoneController,
          placeholder: '请输入手机号',
          keyboardType: TextInputType.phone,
          prefixWidget: GestureDetector(
            onTap: () {
              // TODO: Show country picker bottom sheet
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.only(right: 16.w),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFDCDFE6))),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedCountryCode,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: const Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16.sp, color: const Color(0xFF333333)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        _buildFieldLabel('验证码'),
        _buildInputField(
          controller: _smsCodeController,
          placeholder: '请输入验证码',
          keyboardType: TextInputType.number,
          suffixIcon: GestureDetector(
            onTap: () {
              // TODO: Send SMS logic
            },
            child: Padding(
              padding: EdgeInsets.only(left: 16.w),
              child: Text(
                '获取验证码',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
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
