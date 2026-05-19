import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/auth/auth_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _realNameController = TextEditingController();
  final _payPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedAreaCode = '+86';
  int _phoneCountdown = 0;
  int _emailCountdown = 0;
  Timer? _timer;

  static const _countryCodes = <Map<String, String>>[
    {'name': '中国', 'code': '+86'},
    {'name': '中国香港', 'code': '+852'},
    {'name': '中国澳门', 'code': '+853'},
    {'name': '中国台湾', 'code': '+886'},
    {'name': '美国/加拿大', 'code': '+1'},
    {'name': '日本', 'code': '+81'},
    {'name': '韩国', 'code': '+82'},
    {'name': '英国', 'code': '+44'},
    {'name': '澳大利亚', 'code': '+61'},
    {'name': '新加坡', 'code': '+65'},
    {'name': '马来西亚', 'code': '+60'},
    {'name': '泰国', 'code': '+66'},
    {'name': '法国', 'code': '+33'},
    {'name': '德国', 'code': '+49'},
    {'name': '意大利', 'code': '+39'},
    {'name': '西班牙', 'code': '+34'},
    {'name': '俄罗斯', 'code': '+7'},
    {'name': '印度', 'code': '+91'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _realNameController.dispose();
    _payPasswordController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 28.h),
          child: Column(
            children: [
              _buildHero(context),
              SizedBox(height: 14.h),
              _buildFormCard(authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0369A1).withValues(alpha: 0.22),
            blurRadius: 26.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24.w,
            top: -28.h,
            child: Container(
              width: 118.w,
              height: 118.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.11),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Icon(Icons.verified_user_outlined,
                        size: 30.sp, color: Colors.white),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.go('/login'),
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child:
                          Icon(Icons.close, color: Colors.white, size: 21.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Text(
                _authText('resetPasswordHeader', '找回密码'),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.08,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _authText('resetPasswordDesc', '请选择验证方式并设置新密码'),
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: [
                  _buildTag(_authText('resetPasswordSafeVerify', '安全验证'),
                      light: true),
                  _buildTag(_authText('resetPasswordChangePass', '修改密码'),
                      light: true),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C4A6E).withValues(alpha: 0.08),
            blurRadius: 28.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeTabs(),
          SizedBox(height: 18.h),
          SizedBox(
            height: 244.h,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPhoneTab(authProvider),
                _buildEmailTab(authProvider),
                _buildRealTab(),
              ],
            ),
          ),
          _buildPasswordFields(),
          SizedBox(height: 22.h),
          _buildSubmitButton(authProvider),
          SizedBox(height: 14.h),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.go('/login'),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Text(
                  _authText('resetPasswordActionBackLogin', '返回登录'),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF0369A1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs() {
    final labels = [
      _authText('resetPasswordTabPhone', '手机号'),
      _authText('resetPasswordTabEmail', '邮箱'),
      _authText('resetPasswordTabReal', '实名验证'),
    ];
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _tabController.index == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _tabController.animateTo(index);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(999.r),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFF0369A1).withValues(alpha: 0.12),
                            blurRadius: 12.r,
                            offset: Offset(0, 4.h),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? const Color(0xFF0369A1)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider) {
    final submitting = authProvider.isResettingPassword;
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: submitting
              ? const LinearGradient(
                  colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF0369A1), Color(0xFF22C55E)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: submitting
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF0369A1).withValues(alpha: 0.22),
                    blurRadius: 18.r,
                    offset: Offset(0, 8.h),
                  ),
                ],
        ),
        child: ElevatedButton.icon(
          onPressed: submitting ? null : () => _submit(authProvider),
          icon: Icon(Icons.lock_reset_rounded, size: 20.sp),
          label: Text(
            submitting
                ? 'common.submitting'.tr()
                : _authText('resetPasswordActionSubmit', '确认修改'),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTab(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_authText('resetPasswordFieldPhone', '手机号')),
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE0F2FE)),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedAreaCode,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: const Color(0xFF0C4A6E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.keyboard_arrow_down_rounded,
                        size: 17.sp, color: const Color(0xFF0369A1)),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomTextField(
                controller: _phoneController,
                hintText: 'auth.enterPhone'.tr(),
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildFieldLabel(_authText('resetPasswordFieldCode', '验证码')),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _codeController,
                hintText: 'auth.enterCode'.tr(),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed:
                    _phoneCountdown > 0 || authProvider.isSendingResetCode
                        ? null
                        : () => _sendCode(type: 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0F2FE),
                  foregroundColor: const Color(0xFF0369A1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  _phoneCountdown > 0
                      ? 'common.reacquireCountdown'
                          .tr(namedArgs: {'seconds': '$_phoneCountdown'})
                      : 'common.getCode'.tr(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailTab(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_authText('resetPasswordFieldEmail', '邮箱地址')),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _emailController,
          hintText: 'auth.enterEmail'.tr(),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        _buildFieldLabel(_authText('resetPasswordFieldCode', '验证码')),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _codeController,
                hintText: 'auth.enterCode'.tr(),
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed:
                    _emailCountdown > 0 || authProvider.isSendingResetCode
                        ? null
                        : () => _sendCode(type: 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0F2FE),
                  foregroundColor: const Color(0xFF0369A1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  _emailCountdown > 0
                      ? 'common.reacquireCountdown'
                          .tr(namedArgs: {'seconds': '$_emailCountdown'})
                      : 'common.getCode'.tr(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRealTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_authText('resetPasswordFieldRealName', '真实姓名')),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _realNameController,
          hintText: 'auth.enterRealName'.tr(),
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: 16.h),
        _buildFieldLabel(_authText('resetPasswordFieldSafePassword', '取款密码')),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _payPasswordController,
          hintText:
              _authText('resetPasswordPlaceholderSafePassword', '请输入6位取款密码'),
          keyboardType: TextInputType.number,
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(_authText('resetPasswordFieldNewPassword', '新密码')),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _newPasswordController,
          hintText: 'auth.enterNewPassword'.tr(),
          obscureText: true,
        ),
        SizedBox(height: 16.h),
        _buildFieldLabel(
            _authText('resetPasswordFieldConfirmPassword', '确认新密码')),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: _confirmPasswordController,
          hintText: 'auth.enterConfirmPassword'.tr(),
          obscureText: true,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0C4A6E),
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildTag(String text, {bool light = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.16)
            : const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(999.r),
        border: light
            ? Border.all(color: Colors.white.withValues(alpha: 0.22))
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: light ? Colors.white : const Color(0xFF0369A1),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _showCountryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) => SafeArea(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _countryCodes.length,
          itemBuilder: (context, index) {
            final item = _countryCodes[index];
            final code = item['code'] ?? '+86';
            return ListTile(
              title: Text(item['name'] ?? ''),
              trailing: Text(code),
              onTap: () => Navigator.of(context).pop(code),
            );
          },
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedAreaCode = selected);
  }

  void _sendCode({required int type}) async {
    final authProvider = context.read<AuthProvider>();
    try {
      if (type == 1) {
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) {
          _showSnack('auth.enterPhone'.tr());
          return;
        }
        await authProvider.sendResetPasswordCode(
          type: 1,
          areaCode: _selectedAreaCode,
          phone: phone,
        );
        _startCountdown(phone: true);
      } else {
        final email = _emailController.text.trim();
        if (email.isEmpty) {
          _showSnack('auth.enterEmail'.tr());
          return;
        }
        await authProvider.sendResetPasswordCode(type: 2, email: email);
        _startCountdown(phone: false);
      }
      if (!mounted) return;
      _showSnack('auth.codeSent'.tr());
    } catch (_) {
      if (!mounted) return;
      _showSnack(authProvider.error ?? 'common.loadFailed'.tr());
    }
  }

  void _startCountdown({required bool phone}) {
    _timer?.cancel();
    setState(() {
      if (phone) {
        _phoneCountdown = 60;
      } else {
        _emailCountdown = 60;
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (phone) {
          if (_phoneCountdown <= 1) {
            _phoneCountdown = 0;
            timer.cancel();
          } else {
            _phoneCountdown -= 1;
          }
        } else {
          if (_emailCountdown <= 1) {
            _emailCountdown = 0;
            timer.cancel();
          } else {
            _emailCountdown -= 1;
          }
        }
      });
    });
  }

  Future<void> _submit(AuthProvider authProvider) async {
    final password = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(password)) {
      _showSnack(_authText('enterNewPassword', '请输入新密码'));
      return;
    }
    if (password != confirm) {
      _showSnack(_authText('passwordMismatch', '两次输入的密码不一致'));
      return;
    }

    ResetPasswordRequest request;
    switch (_tabController.index) {
      case 0:
        final phone = _phoneController.text.trim();
        final code = _codeController.text.trim();
        if (phone.isEmpty) {
          _showSnack('auth.enterPhone'.tr());
          return;
        }
        if (code.isEmpty) {
          _showSnack('auth.enterCode'.tr());
          return;
        }
        request = ResetPasswordRequest(
          type: 1,
          areaCode: _selectedAreaCode,
          phone: phone,
          code: code,
          password: password,
        );
        break;
      case 1:
        final email = _emailController.text.trim();
        final code = _codeController.text.trim();
        if (email.isEmpty) {
          _showSnack('auth.enterEmail'.tr());
          return;
        }
        if (code.isEmpty) {
          _showSnack('auth.enterCode'.tr());
          return;
        }
        request = ResetPasswordRequest(
          type: 2,
          email: email,
          code: code,
          password: password,
        );
        break;
      default:
        final realName = _realNameController.text.trim();
        final payPassword = _payPasswordController.text.trim();
        if (realName.isEmpty) {
          _showSnack('auth.enterRealName'.tr());
          return;
        }
        if (!RegExp(r'^\d{6}$').hasMatch(payPassword)) {
          _showSnack(
            _authText('resetPasswordRuleSafePassword', '取款密码必须为6位数字'),
          );
          return;
        }
        request = ResetPasswordRequest(
          type: 3,
          realName: realName,
          payPassword: payPassword,
          password: password,
        );
        break;
    }

    try {
      await authProvider.resetPassword(request);
      if (!mounted) return;
      _showSnack('common.save'.tr());
      context.go('/login');
    } catch (_) {
      if (!mounted) return;
      _showSnack(authProvider.error ?? 'common.loadFailed'.tr());
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _authText(String key, String fallback) {
    final localeKey = 'auth.$key';
    final value = localeKey.tr();
    return value == localeKey ? fallback : value;
  }
}
