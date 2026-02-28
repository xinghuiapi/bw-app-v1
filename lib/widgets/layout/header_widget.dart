import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/language_provider.dart';
import '../common/skeleton_widget.dart';
import '../common/web_safe_image.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.read(homeDataProvider);
    final currentLang = ref.read(languageProvider);

    homeDataAsync.whenData((homeData) {
      final languages = homeData.langConfig ?? [];
      if (languages.isEmpty) return;

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
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '选择语言',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final lang = languages[index];
                      final isSelected = lang.code == currentLang;

                      return ListTile(
                        leading: lang.img != null
                            ? WebSafeImage(
                                imageUrl: lang.img!,
                                width: 24,
                                height: 24,
                              )
                            : const Icon(Icons.language, size: 24),
                        title: Text(
                          lang.name ?? '',
                          style: TextStyle(
                            color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppTheme.primary)
                            : null,
                        onTap: () {
                          if (lang.code != null) {
                            ref.read(languageProvider.notifier).setLanguage(lang.code!);
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leadingWidth: 140,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: homeDataAsync.when(
          data: (homeData) => homeData.siteConfig?.logo != null
              ? WebSafeImage(
                  imageUrl: homeData.siteConfig!.logo!,
                  height: 32,
                  fit: BoxFit.contain,
                  placeholder: const Skeleton(width: 80, height: 20),
                  errorWidget: _buildLogoPlaceholder(homeData.siteConfig?.title),
                )
              : _buildLogoPlaceholder(homeData.siteConfig?.title),
          loading: () => const Center(child: Skeleton(width: 80, height: 20)),
          error: (_, _) => _buildLogoPlaceholder(null),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 22),
        ),
        IconButton(
          onPressed: () => _showLanguageSelector(context, ref),
          icon: const Icon(Icons.language, color: AppTheme.textSecondary, size: 22),
        ),
        Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
            icon: const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 22),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildLogoPlaceholder(String? title) {
    return Center(
      child: Text(
        title ?? 'Cloud Gaming',
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
