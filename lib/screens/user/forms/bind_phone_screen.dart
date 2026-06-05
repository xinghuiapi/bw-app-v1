import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../models/user/user_models.dart';
import '../../../providers/user/user_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/country_dial_options.dart';
import '../../../widgets/custom_nav_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/countdown_button.dart';
import 'user_form_feedback.dart';

class BindPhoneScreen extends StatefulWidget {
  const BindPhoneScreen({super.key});

  @override
  State<BindPhoneScreen> createState() => _BindPhoneScreenState();
}

class _BindPhoneScreenState extends State<BindPhoneScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String _selectedCountryCode = '+86';

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final profile = provider.profile;
    final isBound = profile?.isPhoneBound ?? false;
    final isSubmitting = provider.isSubmitting;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomNavBar(title: 'account.bindPhone'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBound) ...[
                _BoundStatusCard(
                  icon: Icons.phone_iphone,
                  title: 'account.phoneBoundTitle'.tr(),
                  value: _maskPhone(profile!.phone!),
                  message: 'account.phoneBoundMessage'.tr(),
                ),
                SizedBox(height: 24.h),
                CustomButton(text: 'common.back'.tr(), onPressed: _exitPage),
              ] else ...[
                Text(
                  'account.phoneNumber'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: 'account.enterPhoneNumber'.tr(),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: GestureDetector(
                    onTap: _showCountryPicker,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCountryCode,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            size: 16.sp, color: AppColors.textPrimary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'account.verifyCode'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  hintText: 'account.enterVerifyCode'.tr(),
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  suffixIcon: CountdownButton(
                    onPressed: _sendCode,
                  ),
                ),
                SizedBox(height: 48.h),
                CustomButton(
                  text: isSubmitting
                      ? 'common.binding'.tr()
                      : 'common.confirmBind'.tr(),
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _submit,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (!_isPhone(phone)) {
      _showMessage('account.enterValidPhone'.tr());
      return;
    }
    if (code.isEmpty) {
      _showMessage('account.enterVerifyCode'.tr());
      return;
    }

    final provider = context.read<UserProvider>();
    if (provider.isSubmitting) return;
    try {
      await provider.updateProfile(
        UserProfileUpdateRequest(
          phone: phone,
          areaCode: _selectedCountryCode,
          code: code,
        ),
      );
      if (!mounted) return;
      _showMessage('account.bindSuccess'.tr());
      _exitPage();
    } catch (error) {
      if (!mounted) return;
      _showMessage(userFormErrorMessage(error, 'account.bindFailed'.tr()));
    }
  }

  Future<bool> _sendCode() async {
    final phone = _phoneController.text.trim();
    if (!_isPhone(phone)) {
      _showMessage('account.enterValidPhone'.tr());
      return false;
    }

    try {
      final result = await context.read<UserProvider>().sendPhoneCode(
            phone: phone,
            areaCode: _selectedCountryCode,
          );
      if (!mounted) return false;
      _showMessage(_localizedResultMessage(result.message));
      return true;
    } catch (error) {
      if (!mounted) return false;
      _showMessage(userFormErrorMessage(error, 'account.sendCodeFailed'.tr()));
      return false;
    }
  }

  bool _isPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (_selectedCountryCode == '+86')
      return RegExp(r'^1\d{10}$').hasMatch(digits);
    return RegExp(r'^\d{5,18}$').hasMatch(digits);
  }

  String _maskPhone(String value) {
    final text = value.trim();
    if (text.length < 7) return text;
    return '${text.substring(0, 3)}****${text.substring(text.length - 4)}';
  }

  String _localizedResultMessage(String message) {
    final text = message.trim();
    return text.startsWith('auth.') ? text.tr() : text;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _exitPage() {
    context.canPop() ? context.pop() : context.go('/profile');
  }

  Future<void> _showCountryPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        var keyword = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final normalized = keyword.trim().toLowerCase();
            final countries = normalized.isEmpty
                ? countryDialOptions
                : countryDialOptions
                    .where((item) => item.matches(normalized, context))
                    .toList(growable: false);
            return SafeArea(
              child: SizedBox(
                height: 0.78.sh,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            child: Text('common.cancel'.tr()),
                          ),
                          Expanded(
                            child: Text(
                              _authText('countryCode', 'Select country/region'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 64.w),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextField(
                        onChanged: (value) =>
                            setSheetState(() => keyword = value),
                        decoration: InputDecoration(
                          hintText: _authText(
                              'searchCountry', 'Search country or code'),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF5F6F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount: countries.length,
                        itemBuilder: (context, index) {
                          final item = countries[index];
                          return ListTile(
                            title: Text(item.displayName(context)),
                            trailing: Text(item.code),
                            selected: item.code == _selectedCountryCode,
                            onTap: () =>
                                Navigator.of(sheetContext).pop(item.code),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    setState(() => _selectedCountryCode = selected);
  }

  String _authText(String key, String fallback) {
    final fullKey = 'auth.$key';
    final value = fullKey.tr();
    return value == fullKey ? fallback : value;
  }
}

class _BoundStatusCard extends StatelessWidget {
  const _BoundStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String value;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
