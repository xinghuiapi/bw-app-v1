import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/providers/home_provider.dart';
import 'package:my_flutter_app/providers/game_launcher_provider.dart';
import 'package:my_flutter_app/providers/game_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/utils/constants.dart';

class GameCategoriesWidget extends ConsumerWidget {
  final List<GameCategory> categories;

  const GameCategoriesWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final selectedTabIndex = ref.watch(selectedCategoryIndexProvider);

    if (selectedTabIndex < 0 || selectedTabIndex >= categories.length) {
      return const SizedBox.shrink();
    }

    // 移除 IndexedStack，避免同时构建和渲染所有分类下的游戏列表（会创建大量 HtmlElementView 导致内存泄漏和崩溃）
    return _CategoryContentView(
      category: categories[selectedTabIndex],
      categories: categories,
    );
  }
}

/// 单个分类的内容视图，负责处理该分类下的提供商列表或游戏列表
class _CategoryContentView extends ConsumerWidget {
  final GameCategory category;
  final List<GameCategory> categories;

  const _CategoryContentView({
    required this.category,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSubCategory = ref.watch(categorySelectionProvider(category.code ?? ''));

    // 如果已经选择了二级分类且不是 "推荐"，则显示游戏列表
    if (selectedSubCategory != null && category.code != 'reco') {
      return _GameListContent(
        category: category,
        subCategory: selectedSubCategory,
      );
    }

    final subCategoriesAsync = ref.watch(subCategoriesProvider(category.code ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // 二级分类内容
        subCategoriesAsync.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (subCategories) {
            if (subCategories.isEmpty) {
              return const EmptyStateWidget(
                message: '该分类下暂无提供商',
                icon: Icons.grid_off_outlined,
              );
            }

            // 如果是一级分类是 "推荐"，直接显示（它们本身就是游戏/快速进入）
            if (category.code == 'reco') {
              return _buildSubCategoryGrid(context, ref, subCategories, isReco: true);
            }

            // 否则显示二级分类（提供商列表）
            return _buildSubCategoryGrid(context, ref, subCategories, isReco: false);
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CategorySkeleton(),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: '加载二级分类失败: $err',
            onRetry: () => ref.invalidate(subCategoriesProvider(category.code ?? '')),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryGrid(BuildContext context, WidgetRef ref, List<SubCategory> items, {required bool isReco}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isReco ? 1.0 : 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(context, ref, item, isReco);
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, SubCategory item, bool isReco) {
    String imageUrl = item.h5Logo ?? item.img ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
      final baseUrl = AppConstants.resourceBaseUrl.endsWith('/')
          ? AppConstants.resourceBaseUrl.substring(0, AppConstants.resourceBaseUrl.length - 1)
          : AppConstants.resourceBaseUrl;
      final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
      imageUrl = '$baseUrl$path';
    }

    return GestureDetector(
      onTap: () {
        if (isReco) {
          ref.read(gameLauncherProvider).launchGame(context, item, isCategoryEntry: true, categoryCode: 'reco');
        } else {
          final code = (category.code ?? '').toLowerCase().trim();
          final isMultiGameCategory = ['game', 'poker', 'fishing'].contains(code);

          if (!isMultiGameCategory) {
            ref.read(gameLauncherProvider).launchGame(context, item, categoryCode: category.code);
            return;
          }

          if (item.category == 1) {
            ref.read(categorySelectionProvider(category.code ?? '').notifier).set(item);
          } else {
            ref.read(gameLauncherProvider).launchGame(context, item, categoryCode: category.code);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getInputBorderColor(context), width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                WebSafeImage(
                  imageUrl: imageUrl,
                  fit: isReco ? BoxFit.contain : BoxFit.cover,
                  alignment: isReco ? Alignment.center : Alignment.topCenter,
                  placeholder: const Skeleton(),
                  errorWidget: Container(
                    color: AppTheme.surface,
                    child: const Icon(Icons.gamepad, color: AppTheme.textTertiary),
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(20),
                        Colors.black.withAlpha(160),
                      ],
                      stops: const [0.5, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 4,
                right: 4,
                bottom: 4,
                child: Text(
                  item.title ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha(180),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 一级分类 Tab 组件 (可作为吸顶 Header)
class GameCategoryTabs extends ConsumerWidget {
  final List<GameCategory> categories;

  const GameCategoryTabs({super.key, required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final selectedTabIndex = ref.watch(selectedCategoryIndexProvider);

    return Container(
      height: 56,
      width: double.infinity,
      color: AppTheme.getScaffoldBackgroundColor(context),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedTabIndex == index;

          String imageUrl = (isSelected ? category.seImg : category.img) ?? '';
          if (isSelected && imageUrl.isEmpty) {
            imageUrl = category.img ?? '';
          }

          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
            final baseUrl = AppConstants.resourceBaseUrl.endsWith('/')
                ? AppConstants.resourceBaseUrl.substring(0, AppConstants.resourceBaseUrl.length - 1)
                : AppConstants.resourceBaseUrl;
            final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
            imageUrl = '$baseUrl$path';
          }

          return GestureDetector(
            onTap: () {
              ref.read(selectedCategoryIndexProvider.notifier).set(index);
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.getInputBorderColor(context),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl.isNotEmpty) ...[
                    WebSafeImage(
                      imageUrl: imageUrl,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorWidget: const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    category.title ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 游戏列表内容
class _GameListContent extends ConsumerStatefulWidget {
  final GameCategory category;
  final SubCategory subCategory;

  const _GameListContent({
    required this.category,
    required this.subCategory,
  });

  @override
  ConsumerState<_GameListContent> createState() => _GameListContentState();
}

class _GameListContentState extends ConsumerState<_GameListContent> {
  int _selectedSubTabIndex = 0; // 0: 全部游戏, 1: 我的收藏

  @override
  Widget build(BuildContext context) {
    final params = GameListParams(
      game: widget.subCategory.gamecode ?? '',
      code: widget.category.code ?? '',
      size: 30,
    );

    final gameState = ref.watch(gameListProvider(params));
    final subCategoriesAsync = ref.watch(subCategoriesProvider(widget.category.code ?? ''));

    // 监听滚动到底部事件
    ref.listen(scrollBottomProvider, (previous, next) {
      if (next == true) {
        ref.read(gameListProvider(params).notifier).loadMore();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部二级分类切换导航
        subCategoriesAsync.when(
          skipLoadingOnReload: true,
          skipLoadingOnRefresh: true,
          data: (subCategories) => Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subCategories.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = subCategories[index];
                final isSelected = item.gamecode == widget.subCategory.gamecode;

                String imageUrl = item.h5Logo ?? item.img ?? '';
                if (imageUrl.startsWith('/')) {
                  imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
                }

                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      ref.read(categorySelectionProvider(widget.category.code ?? '').notifier).set(item);
                      setState(() => _selectedSubTabIndex = 0);
                    }
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.getDividerColor(context),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: WebSafeImage(
                              imageUrl: imageUrl,
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                              errorWidget: const SizedBox.shrink(),
                            ),
                          )
                        else
                          Icon(Icons.gamepad, size: 24, color: AppTheme.getTertiaryTextColor(context)),
                        const SizedBox(height: 4),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primary : AppTheme.getSecondaryTextColor(context),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          loading: () => const SizedBox(height: 80),
          error: (_, __) => const SizedBox(height: 80),
        ),

        Divider(height: 1, color: AppTheme.getDividerColor(context)),

        // 搜索和子页签
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.getSecondaryTextColor(context), size: 20),
                onPressed: () {
                  ref.read(categorySelectionProvider(widget.category.code ?? '').notifier).set(null);
                },
              ),
              IconButton(
                icon: Icon(Icons.search, color: AppTheme.getSecondaryTextColor(context), size: 22),
                onPressed: () {
                  // TODO: 实现子游戏搜索
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.getInputFillColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildSubTabItem('全部游戏', 0),
                      _buildSubTabItem('我的收藏', 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildGameListContent(gameState, params),
      ],
    );
  }

  Widget _buildSubTabItem(String title, int index) {
    final isSelected = _selectedSubTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSubTabIndex = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameListContent(GameListPaginationState state, GameListParams params) {
    if (state.currentPage == 0 && state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CategorySkeleton(),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return ErrorStateWidget(
        message: '加载游戏失败: ${state.error}',
        onRetry: () => ref.read(gameListProvider(params).notifier).loadMore(),
      );
    }

    final games = _selectedSubTabIndex == 1
        ? state.items.where((game) => game.isFavorite).toList()
        : state.items;

    if (games.isEmpty && !state.isLoading) {
      return EmptyStateWidget(
        message: _selectedSubTabIndex == 1 ? '暂无收藏游戏' : '该分类下暂无游戏',
        icon: _selectedSubTabIndex == 1 ? Icons.favorite_border : Icons.sports_esports_outlined,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return _buildGameCard(game, params);
            },
          ),
        ),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
              ),
            ),
          ),
        if (!state.hasMore && games.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '没有更多游戏了',
                style: TextStyle(color: AppTheme.getTertiaryTextColor(context), fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameCard(GameItem game, GameListParams params) {
    String imageUrl = game.img ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http') && !imageUrl.startsWith('assets/')) {
      final baseUrl = AppConstants.resourceBaseUrl.endsWith('/')
          ? AppConstants.resourceBaseUrl.substring(0, AppConstants.resourceBaseUrl.length - 1)
          : AppConstants.resourceBaseUrl;
      final path = imageUrl.startsWith('/') ? imageUrl : '/$imageUrl';
      imageUrl = '$baseUrl$path';
    }

    return GestureDetector(
      onTap: () => ref.read(gameLauncherProvider).launchGame(context, game, categoryCode: params.code),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.getDividerColor(context), width: 0.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    WebSafeImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: const Skeleton(),
                    ),
                    // 拦截 HtmlElementView 的点击事件，使其冒泡到外层的 GestureDetector
                    Positioned.fill(
                      child: Container(color: Colors.transparent),
                    ),
                    // 收藏按钮
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () async {
                          if (game.id != null) {
                            // 检查登录状态
                            if (!ref.read(authProvider).isLoggedIn) {
                              ToastUtils.showInfo('请先登录以收藏游戏');
                              return;
                            }

                            // 本地先切换，提供即时反馈
                            ref.read(gameListProvider(params).notifier).toggleFavoriteLocal(game.id!);
                            
                            // 计算目标状态
                            final targetStatus = game.isFavorite ? 0 : 1;
                            final success = await ref.read(userProvider.notifier).toggleFavorite(game.id!, targetStatus);
                            
                            if (!success) {
                              // 如果失败，回退本地状态
                              ref.read(gameListProvider(params).notifier).toggleFavoriteLocal(game.id!);
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            game.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            color: game.isFavorite ? AppTheme.primary : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            game.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
