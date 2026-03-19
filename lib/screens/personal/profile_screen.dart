import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/services/user_service.dart';
import 'package:my_flutter_app/models/user.dart';
import 'package:my_flutter_app/models/user_models.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/utils/constants.dart';

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
      return Scaffold(
        backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        title: Text(
          '个人资料',
          style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
        ),
        backgroundColor: AppTheme.getCardColor(context),
        foregroundColor: AppTheme.getPrimaryTextColor(context),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppTheme.getPrimaryTextColor(context)),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(userProvider.notifier).fetchUserInfo(),
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
                        onTap: () =>
                            context.push('/personal-center-profile-realname'),
                      ),
                      _buildSettingsCell(
                        label: '支付密码',
                        value: (user?.payPassword == true) ? '已设置' : '未设置',
                        onTap: () => context.push(
                          '/personal-center-profile-paypassword',
                        ),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // 账号信息
                    _buildSectionTitle('账号信息'),
                    _buildSettingsGroup([
                      _buildSettingsCell(
                        label: '手机号码',
                        value: user?.phone ?? '未设置',
                        onTap: () =>
                            context.push('/personal-center-profile-phone'),
                      ),
                      _buildSettingsCell(
                        label: '邮箱地址',
                        value: user?.email ?? '未设置',
                        onTap: () =>
                            context.push('/personal-center-profile-email'),
                      ),
                    ]),

                    const SizedBox(height: 16),

                    // 个人信息
                    _buildSectionTitle('个人信息'),
                    _buildSettingsGroup([
                      _buildSettingsCell(
                        label: '性别',
                        value: user?.gender ?? '未设置',
                        onTap: () =>
                            context.push('/personal-center-profile-gender'),
                      ),
                      _buildSettingsCell(
                        label: '出生日期',
                        value: user?.bornTime ?? '未设置',
                        onTap: () =>
                            context.push('/personal-center-profile-borntime'),
                      ),
                      _buildSettingsCell(
                        label: 'QQ号',
                        value: user?.qq != null ? user!.qq.toString() : '未设置',
                        onTap: () =>
                            context.push('/personal-center-profile-qq'),
                      ),
                      _buildSettingsCell(
                        label: 'Telegram',
                        value: user?.telegram ?? '未设置',
                        onTap: () =>
                            context.push('/personal-center-profile-telegram'),
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
      color: AppTheme.getCardColor(context),
      child: GestureDetector(
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
                            color: AppTheme.primary.withAlpha(26),
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: AppTheme.primary,
                            ),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: AppTheme.primary.withAlpha(26),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                        ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
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
                    style: TextStyle(
                      color: AppTheme.getPrimaryTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? user?.email ?? '未设置联系方式',
                    style: TextStyle(
                      color: AppTheme.getSecondaryTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.getTertiaryTextColor(context),
            ),
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
        style: TextStyle(
          color: AppTheme.getTertiaryTextColor(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    final dividerColor = AppTheme.getDividerColor(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        border: Border(
          top: BorderSide(color: dividerColor, width: 0.5),
          bottom: BorderSide(color: dividerColor, width: 0.5),
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
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Divider(height: 0.5, color: dividerColor),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Ensures the entire row is clickable
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.getPrimaryTextColor(context),
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.getSecondaryTextColor(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: AppTheme.getTertiaryTextColor(context),
              size: 18,
            ),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('头像更新成功')));
              ref.read(userProvider.notifier).fetchUserInfo();
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(updateResponse.msg ?? '头像更新失败')),
              );
            }
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.msg ?? '图片上传失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
