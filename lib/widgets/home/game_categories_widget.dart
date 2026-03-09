import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/providers/home_provider.dart';
import 'package:my_flutter_app/providers/game_launcher_provider.dart';
import 'package:my_flutter_app/providers/game_provider.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/utils/constants.dart';

class GameCategoriesWidget extends ConsumerStatefulWidget {
  final List<GameCategory> categories;

  const GameCategoriesWidget({super.key, required this.categories});

  @override
  ConsumerState<GameCategoriesWidget> createState() => _GameCategoriesWidgetState();
}

class _GameCategoriesWidgetState extends ConsumerState<GameCategoriesWidget> {
  int _selectedTabIndex = 0;
  SubCategory? _selectedSubCategory;

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final selectedCategory = widget.categories[_selectedTabIndex];
    
    // 如果已经选择了二级分类且不是 "推荐"，则显示游戏列表
    if (_selectedSubCategory != null && selectedCategory.code != 'reco') {
      return _buildGameList(selectedCategory, _selectedSubCategory!);
    }

    final subCategoriesAsync = ref.watch(subCategoriesProvider(selectedCategory.code ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 一级分类 Tab
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                    _selectedSubCategory = null; // 重置二级分类
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white.withAlpha(13),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    category.title ?? '',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // 二级分类内容
        subCategoriesAsync.when(
          data: (subCategories) {
            if (subCategories.isEmpty) {
              return const EmptyStateWidget(
                message: '该分类下暂无提供商',
                icon: Icons.grid_off_outlined,
              );
            }

            // 如果是一级分类是 "推荐"，直接显示（它们本身就是游戏/快速进入）
            if (selectedCategory.code == 'reco') {
              return _buildSubCategoryGrid(subCategories, isReco: true);
            }

            // 否则显示二级分类（提供商列表）
            return _buildSubCategoryGrid(subCategories, isReco: false);
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CategorySkeleton(),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: '加载二级分类失败: $err',
            onRetry: () => ref.invalidate(subCategoriesProvider(selectedCategory.code ?? '')),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategoryGrid(List<SubCategory> items, {required bool isReco}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isReco ? 3 : 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isReco ? 0.8 : 1.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(item, isReco);
        },
      ),
    );
  }

  Widget _buildItemCard(SubCategory item, bool isReco) {
    // 补全图片 URL
    String imageUrl = item.h5Logo ?? item.img ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
    }

    return GestureDetector(
      onTap: () {
        if (isReco) {
          // 推荐分类下的点击直接启动
          ref.read(gameLauncherProvider).launchGame(context, item, isCategoryEntry: true, categoryCode: 'reco');
        } else {
          final category = widget.categories[_selectedTabIndex];
          // 根据 category 字段判断是进入二级页面还是直接启动
          // category: 1 -> 有二级游戏列表
          // category: 0 -> 直接启动游戏
          // 调试日志
          debugPrint('Tap Category: ${category.code}, Item Category: ${item.category}, Title: ${item.title}');

          // 额外增加判断：只有 game/poker/fishing 分类才允许进入二级页面
          // 忽略大小写和空格
          final code = (category.code ?? '').toLowerCase().trim();
          final isMultiGameCategory = ['game', 'poker', 'fishing'].contains(code);
          
          // 如果是一级分类，且不在 game/poker/fishing 中，强制直接启动
          if (!isMultiGameCategory) {
             ref.read(gameLauncherProvider).launchGame(context, item, categoryCode: category.code);
             return;
          }

          if (item.category == 1) {
            setState(() {
              _selectedSubCategory = item;
            });
          } else {
            ref.read(gameLauncherProvider).launchGame(context, item, categoryCode: category.code);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(13), width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl.isNotEmpty)
                WebSafeImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: const Skeleton(),
                  errorWidget: Container(
                    color: AppTheme.surface,
                    child: const Icon(Icons.gamepad, color: AppTheme.textTertiary),
                  ),
                ),
              if (true) // 无论是推荐还是普通分类，都添加底部遮罩以增强文字可读性
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(0),
                        Colors.black.withAlpha(204),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item.title ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isReco ? 12 : 14,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(204),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameList(GameCategory category, SubCategory subCategory) {
    final params = GameListParams(
      game: subCategory.gamecode ?? '',
      code: category.code ?? '',
      size: 30,
    );
    
    // 获取 provider 状态
    final gameState = ref.watch(gameListProvider(params));
    
    // 监听滚动到底部事件
    ref.listen(scrollBottomProvider, (previous, next) {
      if (next == true) {
        // 当滚动到底部时，加载更多
        ref.read(gameListProvider(params).notifier).loadMore();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                onPressed: () => setState(() => _selectedSubCategory = null),
              ),
              Text(
                '${subCategory.title} 游戏',
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        _buildGameListContent(gameState, params),
      ],
    );
  }

  Widget _buildGameListContent(GameListPaginationState state, GameListParams params) {
    // 如果是第一页加载中，显示骨架屏
    if (state.currentPage == 0 && state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CategorySkeleton(),
      );
    }
    
    // 如果加载出错且没有数据
    if (state.error != null && state.items.isEmpty) {
      return ErrorStateWidget(
        message: '加载游戏失败: ${state.error}',
        onRetry: () => ref.read(gameListProvider(params).notifier).loadMore(),
      );
    }

    final games = state.items;
    if (games.isEmpty && !state.isLoading) {
      return const EmptyStateWidget(
        message: '该分类下暂无游戏',
        icon: Icons.sports_esports_outlined,
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
              return _buildGameCard(game);
            },
          ),
        ),
        // 加载更多指示器
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
        // 没有更多数据提示
        if (!state.hasMore && games.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '没有更多游戏了',
                style: TextStyle(color: AppTheme.textTertiary.withAlpha(128), fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameCard(GameItem game) {
    String imageUrl = game.img ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
    }

    return GestureDetector(
      onTap: () {
        final category = widget.categories[_selectedTabIndex];
        ref.read(gameLauncherProvider).launchGame(
          context,
          game, 
          categoryCode: category.code,
          isCategoryResult: game.isCategoryResult,
          isHot: game.isHot,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(13), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.isNotEmpty)
                      WebSafeImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: const Skeleton(),
                        errorWidget: Container(
                          color: AppTheme.surface,
                          child: const Icon(Icons.gamepad, color: AppTheme.textTertiary),
                        ),
                      )
                    else
                      Container(
                        color: AppTheme.surface,
                        child: const Icon(Icons.gamepad, color: AppTheme.textTertiary),
                      ),
                    // 添加底部渐变，使文字更清晰
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(128),
                            ],
                            stops: const [0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                game.title ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
