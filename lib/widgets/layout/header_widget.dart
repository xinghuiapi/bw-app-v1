import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/providers/home_provider.dart';
import 'package:my_flutter_app/providers/language_provider.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';
import 'package:my_flutter_app/gen/strings.g.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.read(homeDataProvider);
    final currentLocale = ref.read(languageProvider);

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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    t.common.languageSelectorTitle,
                    style: const TextStyle(
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
                      // 映射 API 返回的语言代码到 AppLocale
                      AppLocale? targetLocale;
                      if (lang.code == 'CN') targetLocale = AppLocale.zh;
                      if (lang.code == 'EN') targetLocale = AppLocale.en;
                      if (lang.code == 'PT') targetLocale = AppLocale.pt;
                      
                      final isSelected = targetLocale == currentLocale;

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
                          if (targetLocale != null) {
                            ref.read(languageProvider.notifier).setLanguage(targetLocale);
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
          data: (homeData) {
            final logoUrl = homeData.siteConfig?.logo;
            // 如果有本地 Logo 文件（需要在 assets 中存在），可以取消注释下面代码
            // return WebSafeImage(imageUrl: AppConstants.localLogoPath, height: 32, fit: BoxFit.contain);
            
            return logoUrl != null
              ? WebSafeImage(
                  imageUrl: logoUrl,
                  height: 32,
                  fit: BoxFit.contain,
                )
              : const SizedBox.shrink();
          },
          loading: () => const Skeleton(width: 100, height: 32),
          error: (err, _) => const SizedBox.shrink(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.textPrimary),
          onPressed: () => context.push('/search'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
