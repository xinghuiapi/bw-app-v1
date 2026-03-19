import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/providers/password_reset_provider.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final type = PasswordResetType.values[_tabController.index];
        ref.read(passwordResetProvider.notifier).setType(type);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(passwordResetProvider.notifier)
        .resetPassword();
    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '重置密码',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '手机找回'),
            Tab(text: '邮箱找回'),
            Tab(text: '安全找回'),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFields(state, notifier),
                const SizedBox(height: 24),
                _buildPasswordFields(state, notifier),
                const SizedBox(height: 40),
                _buildSubmitButton(state.isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '身份验证',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _tabController.index == 2 ? '请输入您的真实姓名和支付密码' : '我们将向您的账号发送验证码',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFields(
    PasswordResetState state,
    PasswordResetNotifier notifier,
  ) {
    if (state.type == PasswordResetType.phone) {
      return Column(
        children: [
          _buildPhoneField(state, notifier),
          const SizedBox(height: 20),
          _buildCodeField(state, notifier),
        ],
      );
    } else if (state.type == PasswordResetType.email) {
      return Column(
        children: [
          _buildTextField(
            label: '邮箱地址',
            hint: '请输入邮箱',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) => notifier.updateField(email: v),
            validator: (v) => (v == null || v.isEmpty) ? '请输入邮箱' : null,
          ),
          const SizedBox(height: 20),
          _buildCodeField(state, notifier),
        ],
      );
    } else {
      return Column(
        children: [
          _buildTextField(
            label: '真实姓名',
            hint: '请输入开户姓名',
            prefixIcon: Icons.person_outline,
            onChanged: (v) => notifier.updateField(realName: v),
            validator: (v) => (v == null || v.isEmpty) ? '请输入真实姓名' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: '支付密码',
            hint: '请输入支付密码',
            prefixIcon: Icons.security_outlined,
            obscureText: true,
            onChanged: (v) => notifier.updateField(payPassword: v),
            validator: (v) => (v == null || v.isEmpty) ? '请输入支付密码' : null,
          ),
        ],
      );
    }
  }

  Widget _buildPhoneField(
    PasswordResetState state,
    PasswordResetNotifier notifier,
  ) {
    return Row(
      children: [
        Container(
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          child: _buildTextField(
            label: '区号',
            hint: '+86',
            initialValue: state.areaCode,
            readOnly: true,
            onTap: () {
              // TODO: Area code picker
            },
          ),
        ),
        Expanded(
          child: _buildTextField(
            label: '手机号',
            hint: '请输入手机号',
            prefixIcon: Icons.phone_iphone,
            keyboardType: TextInputType.phone,
            onChanged: (v) => notifier.updateField(phone: v),
            validator: (v) => (v == null || v.isEmpty) ? '请输入手机号' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeField(
    PasswordResetState state,
    PasswordResetNotifier notifier,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildTextField(
            label: '验证码',
            hint: '请输入验证码',
            prefixIcon: Icons.verified_user_outlined,
            keyboardType: TextInputType.text,
            onChanged: (v) => notifier.updateField(code: v),
            validator: (v) => (v == null || v.isEmpty) ? '请输入验证码' : null,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: (state.countdown > 0 || state.isLoading)
                ? null
                : () => notifier.sendCode(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary.withAlpha(26),
              foregroundColor: AppTheme.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              state.countdown > 0 ? '${state.countdown}s' : '获取验证码',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFields(
    PasswordResetState state,
    PasswordResetNotifier notifier,
  ) {
    return Column(
      children: [
        _buildTextField(
          label: '新密码',
          hint: '请输入 6-20 位新密码',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          onChanged: (v) => notifier.updateField(password: v),
          validator: (v) {
            if (v == null || v.isEmpty) return '请输入新密码';
            if (v.length < 6) return '密码长度不能少于 6 位';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: '确认新密码',
          hint: '请再次输入新密码',
          prefixIcon: Icons.lock_clock_outlined,
          obscureText: true,
          onChanged: (v) => notifier.updateField(confirmPassword: v),
          validator: (v) {
            if (v == null || v.isEmpty) return '请确认新密码';
            if (v != state.password) return '两次输入的密码不一致';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    String? initialValue,
    IconData? prefixIcon,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.textTertiary, size: 20)
                : null,
            filled: true,
            fillColor: AppTheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withAlpha(13)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleReset,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                '重置密码',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
