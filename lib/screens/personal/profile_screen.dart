import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../models/user_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/web_safe_image.dart';
import '../../utils/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 页面进入时刷新一次用户信息
    Future.microtask(() => ref.read(userProvider.notifier).fetchUserInfo());
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    
    // 如果正在全局加载用户信息，显示加载状态
    if (userState.isLoading && user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(userProvider.notifier).fetchUserInfo(),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // 头像及基础信息
                  _buildAvatarSection(user),
                  
                  const SizedBox(height: 16),
                  
                  // 加密信息
                  _buildSectionTitle('加密信息'),
                  _buildSettingsGroup([
                    _buildSettingsCell(
                      label: '真实姓名',
                      value: user?.realName ?? '未设置',
                      onTap: () => context.push('/personal-center-profile-realname'),
                    ),
                    _buildSettingsCell(
                      label: '支付密码',
                      value: (user?.payPassword == true) ? '已设置' : '未设置',
                      onTap: () => context.push('/personal-center-profile-paypassword'),
                    ),
                  ]),
  
                  const SizedBox(height: 16),
  
                  // 账号信息
                  _buildSectionTitle('账号信息'),
                  _buildSettingsGroup([
                    _buildSettingsCell(
                      label: '手机号码',
                      value: user?.phone ?? '未设置',
                      onTap: () => context.push('/personal-center-profile-phone'),
                    ),
                    _buildSettingsCell(
                      label: '邮箱地址',
                      value: user?.email ?? '未设置',
                      onTap: () => context.push('/personal-center-profile-email'),
                    ),
                  ]),
  
                  const SizedBox(height: 16),
  
                  // 个人信息
                  _buildSectionTitle('个人信息'),
                  _buildSettingsGroup([
                    _buildSettingsCell(
                      label: 'QQ号',
                      value: user?.qq != null ? user!.qq.toString() : '未设置',
                      onTap: () => context.push('/personal-center-profile-qq'),
                    ),
                    _buildSettingsCell(
                      label: 'Telegram',
                      value: user?.telegram ?? '未设置',
                      onTap: () => context.push('/personal-center-profile-telegram'),
                    ),
                  ]),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildAvatarSection(User? user) {
    final avatarUrl = user?.img ?? user?.avatarUrl;
    String finalUrl = '';
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      finalUrl = avatarUrl;
      if (!avatarUrl.startsWith('http') && !avatarUrl.startsWith('blob:')) {
        finalUrl = "${AppConstants.resourceBaseUrl}$avatarUrl";
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: AppTheme.surface,
      child: InkWell(
        onTap: _isUploading ? null : _pickAndUploadAvatar,
        child: Row(
          children: [
            Stack(
              children: [
                ClipOval(
                  child: finalUrl.isNotEmpty 
                    ? WebSafeImage(
                        imageUrl: finalUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 70,
                          height: 70,
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.person, size: 40, color: AppTheme.primary),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, size: 40, color: AppTheme.primary),
                      ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.realName ?? '未设置姓名',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? user?.email ?? '未设置联系方式',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(color: AppTheme.textTertiary, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 0.5),
          bottom: BorderSide(color: AppTheme.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final idx = entry.key;
          final widget = entry.value;
          return Column(
            children: [
              widget,
              if (idx < children.length - 1)
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Divider(height: 0.5, color: AppTheme.divider),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsCell({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      final bytes = await image.readAsBytes();
      final response = await UserService.uploadImage(bytes, image.name);

      if (response.code == 200 && response.data != null) {
        final String? avatarUrl = response.data!['url'];
        if (avatarUrl != null) {
          // 上传成功后更新个人资料中的头像字段
          final updateResponse = await UserService.updateUserProfile(
            UserProfileUpdateRequest(img: avatarUrl),
          );

          if (updateResponse.code == 200) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('头像更新成功')));
              ref.read(userProvider.notifier).fetchUserInfo();
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(updateResponse.msg ?? '头像更新失败')));
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.msg ?? '图片上传失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showGenderPicker(BuildContext context, User? user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('选择性别', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(height: 1),
              _buildGenderOption('男', user),
              const Divider(height: 1, indent: 20, endIndent: 20),
              _buildGenderOption('女', user),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String gender, User? user) {
    final isSelected = user?.gender == gender;
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        if (isSelected) return;
        
        setState(() => _isLoading = true);
        final response = await UserService.updateUserProfile(
          UserProfileUpdateRequest(gender: gender),
        );
        
        if (mounted) {
          setState(() => _isLoading = false);
          if (response.code == 200) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
            ref.read(userProvider.notifier).fetchUserInfo();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.msg ?? '更新失败')));
          }
        }
      },
      title: Text(gender, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
      trailing: isSelected ? const Icon(Icons.check, color: AppTheme.primary) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Future<void> _showBirthDatePicker(BuildContext context, User? user) async {
    final DateTime now = DateTime.now();
    DateTime initialDate = now;
    
    if (user?.bornTime != null && user!.bornTime!.isNotEmpty) {
      try {
        initialDate = DateTime.parse(user.bornTime!);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.cardBackground,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      final String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      
      setState(() => _isLoading = true);
      final response = await UserService.updateUserProfile(
        UserProfileUpdateRequest(bornTime: formattedDate),
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (response.code == 200) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('更新成功')));
          ref.read(userProvider.notifier).fetchUserInfo();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.msg ?? '更新失败')));
        }
      }
    }
  }
}
