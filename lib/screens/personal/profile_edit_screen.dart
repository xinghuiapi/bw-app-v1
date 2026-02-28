import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../models/user_models.dart';

enum ProfileEditType {
  realName,
  phone,
  email,
  qq,
  telegram,
  payPassword,
}

class ProfileEditScreen extends ConsumerStatefulWidget {
  final ProfileEditType type;

  const ProfileEditScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _confirmValueController = TextEditingController();
  final _oldPayPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  final _areaCodeController = TextEditingController(text: '86');
  
  bool _isLoading = false;
  bool _isSendingCode = false;
  int _countdown = 0;
  Timer? _timer;
  bool _hasPayPassword = false;
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _initValue();
  }

  void _initValue() {
    final user = ref.read(userProvider).user;
    if (user == null) return;

    _hasPayPassword = user.payPassword ?? false;

    switch (widget.type) {
      case ProfileEditType.realName:
        _currentValue = user.realName ?? '';
        _valueController.text = _currentValue;
        break;
      case ProfileEditType.phone:
        _currentValue = user.phone ?? '';
        break;
      case ProfileEditType.email:
        _currentValue = user.email ?? '';
        break;
      case ProfileEditType.qq:
        _currentValue = user.qq ?? '';
        _valueController.text = _currentValue;
        break;
      case ProfileEditType.telegram:
        _currentValue = user.telegram ?? '';
        _valueController.text = _currentValue;
        break;
      case ProfileEditType.payPassword:
        break;
    }
  }

  String _maskValue(String value) {
    if (value.isEmpty) return '';
    if (widget.type == ProfileEditType.phone) {
      if (value.length <= 7) return value;
      return '${value.substring(0, 3)}****${value.substring(value.length - 4)}';
    } else if (widget.type == ProfileEditType.email) {
      final parts = value.split('@');
      if (parts.length != 2) return value;
      final name = parts[0];
      final domain = parts[1];
      if (name.length <= 2) return '$name****@$domain';
      return '${name.substring(0, 2)}****@$domain';
    }
    return value;
  }

  bool get _hasCurrentValue => _currentValue.isNotEmpty;

  @override
  void dispose() {
    _valueController.dispose();
    _confirmValueController.dispose();
    _oldPayPasswordController.dispose();
    _codeController.dispose();
    _areaCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _title {
    switch (widget.type) {
      case ProfileEditType.realName:
        return _hasCurrentValue ? '修改真实姓名' : '设置真实姓名';
      case ProfileEditType.phone:
        return _hasCurrentValue ? '修改手机号码' : '设置手机号码';
      case ProfileEditType.email:
        return _hasCurrentValue ? '修改邮箱地址' : '设置邮箱地址';
      case ProfileEditType.qq:
        return _hasCurrentValue ? '修改 QQ' : '设置 QQ';
      case ProfileEditType.telegram:
        return _hasCurrentValue ? '修改 Telegram' : '设置 Telegram';
      case ProfileEditType.payPassword:
        return _hasPayPassword ? '修改支付密码' : '设置支付密码';
    }
  }

  String get _label {
    switch (widget.type) {
      case ProfileEditType.realName:
        return '真实姓名';
      case ProfileEditType.phone:
        return _hasCurrentValue ? '新手机号码' : '手机号码';
      case ProfileEditType.email:
        return _hasCurrentValue ? '新邮箱地址' : '邮箱地址';
      case ProfileEditType.qq:
        return 'QQ 号码';
      case ProfileEditType.telegram:
        return 'Telegram 账号';
      case ProfileEditType.payPassword:
        return '支付密码';
    }
  }

  String get _placeholder {
    switch (widget.type) {
      case ProfileEditType.realName:
        return '请输入真实姓名';
      case ProfileEditType.phone:
        return '请输入手机号码';
      case ProfileEditType.email:
        return '请输入邮箱地址';
      case ProfileEditType.qq:
        return '请输入 QQ 号码';
      case ProfileEditType.telegram:
        return '请输入 Telegram 账号';
      case ProfileEditType.payPassword:
        return '请输入 6 位数字支付密码';
    }
  }

  bool get _showCodeField {
    return widget.type == ProfileEditType.phone || widget.type == ProfileEditType.email;
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendCode() async {
    if (_isSendingCode || _countdown > 0) return;

    final value = _valueController.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请输入$_label')));
      return;
    }

    // 手机号/邮箱格式校验
    if (widget.type == ProfileEditType.phone) {
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的手机号')));
        return;
      }
    } else if (widget.type == ProfileEditType.email) {
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入正确的邮箱')));
        return;
      }
    }

    setState(() => _isSendingCode = true);
    try {
      final user = ref.read(userProvider).user;
      final response = widget.type == ProfileEditType.phone
          ? await AuthService.sendSmsCode(value, _areaCodeController.text, type: 2)
          : await AuthService.sendEmailCode(value, username: user?.username, type: 2);

      if (mounted) {
        if (response.code == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('验证码已发送')));
          _startCountdown();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.msg ?? '发送失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingCode = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final value = _valueController.text.trim();
    final code = _codeController.text.trim();

    if (_showCodeField && code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入验证码')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      dynamic response;
      if (widget.type == ProfileEditType.payPassword) {
        response = await UserService.setPayPassword(
          value,
          oldPayPassword: _hasPayPassword ? _oldPayPasswordController.text.trim() : null,
        );
      } else {
        final request = UserProfileUpdateRequest(
          realName: widget.type == ProfileEditType.realName ? value : null,
          phone: widget.type == ProfileEditType.phone ? value : null,
          email: widget.type == ProfileEditType.email ? value : null,
          qq: widget.type == ProfileEditType.qq ? value : null,
          telegram: widget.type == ProfileEditType.telegram ? value : null,
          code: _showCodeField ? code : null,
        );
        response = await UserService.updateUserProfile(request);
      }

      if (mounted) {
        if (response.code == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
          ref.read(userProvider.notifier).fetchUserInfo();
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.msg ?? '更新失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: AppTheme.cardBackground,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_hasCurrentValue && (widget.type == ProfileEditType.phone || widget.type == ProfileEditType.email)) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前${widget.type == ProfileEditType.phone ? "手机号" : "邮箱"}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _maskValue(_currentValue),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.type == ProfileEditType.payPassword && _hasPayPassword) ...[
                const Text(
                  '旧支付密码',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _oldPayPasswordController,
                  decoration: InputDecoration(
                    hintText: '请输入旧支付密码',
                    filled: true,
                    fillColor: AppTheme.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) => (v == null || v.isEmpty) ? '请输入旧支付密码' : null,
                ),
                const SizedBox(height: 20),
              ],
              Text(
                _hasPayPassword ? '新支付密码' : _label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (widget.type == ProfileEditType.phone) ...[
                    Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: TextFormField(
                        controller: _areaCodeController,
                        decoration: InputDecoration(
                          prefixText: '+',
                          hintText: '86',
                          filled: true,
                          fillColor: AppTheme.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                      ),
                    ),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        hintText: _placeholder,
                        filled: true,
                        fillColor: AppTheme.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        counterText: '',
                      ),
                      obscureText: widget.type == ProfileEditType.payPassword,
                      keyboardType: _getKeyboardType(),
                      validator: _validateValue,
                      maxLength: widget.type == ProfileEditType.payPassword ? 6 : null,
                    ),
                  ),
                ],
              ),
              if (widget.type == ProfileEditType.payPassword) ...[
                const SizedBox(height: 20),
                const Text(
                  '确认支付密码',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmValueController,
                  decoration: InputDecoration(
                    hintText: '请再次输入支付密码',
                    filled: true,
                    fillColor: AppTheme.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (v) {
                    if (v == null || v.isEmpty) return '请再次输入支付密码';
                    if (v != _valueController.text) return '两次输入的密码不一致';
                    return null;
                  },
                ),
              ],
              if (_showCodeField) ...[
                const SizedBox(height: 20),
                const Text(
                  '验证码',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          hintText: '请输入验证码',
                          filled: true,
                          fillColor: AppTheme.cardBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_isSendingCode || _countdown > 0) ? null : _sendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: AppTheme.textSecondary.withValues(alpha: 0.3),
                        ),
                        child: Text(
                          _countdown > 0 ? '${_countdown}s' : '获取验证码',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('确认提交', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              if (widget.type == ProfileEditType.realName)
                const _SecurityTip(text: '真实姓名提交后无法修改，如需变更请联系客服。'),
              if (widget.type == ProfileEditType.phone)
                const _SecurityTip(text: '为保障账号安全，请使用本人手机号完成验证。'),
              if (widget.type == ProfileEditType.payPassword)
                const _SecurityTip(text: '支付密码用于提现等敏感操作，请务必牢记。'),
            ],
          ),
        ),
      ),
    ),
  );
}

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case ProfileEditType.phone:
        return TextInputType.phone;
      case ProfileEditType.email:
        return TextInputType.emailAddress;
      case ProfileEditType.payPassword:
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  String? _validateValue(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入$_label';
    }
    if (widget.type == ProfileEditType.payPassword) {
      if (!RegExp(r'^\d{6}$').hasMatch(value)) {
        return '支付密码必须为 6 位数字';
      }
    }
    if (widget.type == ProfileEditType.phone) {
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
        return '请输入正确的手机号';
      }
    }
    if (widget.type == ProfileEditType.email) {
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
        return '请输入正确的邮箱';
      }
    }
    return null;
  }
}

class _SecurityTip extends StatelessWidget {
  final String text;

  const _SecurityTip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
