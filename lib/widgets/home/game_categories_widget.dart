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

class GameCategoriesWidget extends ConsumerStatefulWidget {
  final List<GameCategory> categories;

  const GameCategoriesWidget({super.key, required this.categories});

  @override
  ConsumerState<GameCategoriesWidget> createState() => _GameCategoriesWidgetState();
}

class _GameCategoriesWidgetState extends ConsumerState<GameCategoriesWidget> {
  int _selectedTabIndex = 0;
  SubCategory? _selectedSubCategory;
  int _selectedSubTabIndex = 0; // 0: 全部游戏, 1: 我的收藏

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
                    _selectedSubTabIndex = 0; // 重置子页签
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
          childAspectRatio: isReco ? 1.0 : 1.8, // 推荐位改为 1.0 (正方形) 更好地契合游戏图标
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
            fit: StackFit.expand, // 改回 expand 以确保填满
            children: [
              if (imageUrl.isNotEmpty)
                WebSafeImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover, // 改回 cover 以填满容器
                  placeholder: const Skeleton(),
                  errorWidget: Container(
                    color: AppTheme.surface,
                    child: const Icon(Icons.gamepad, color: AppTheme.textTertiary),
                  ),
                ),
              if (true) // 无论是推荐还是普通分类，都添加底部遮罩以增强文字可读性
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(0),
                          Colors.black.withAlpha(153), // 遮罩稍微变淡一些，不要挡住太多底部图标
                        ],
                        stops: const [0.6, 1.0],
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
                    fontSize: isReco ? 11 : 13, // 字号微调
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

  Widget _buildGameList(GameCategory category, SubCategory subCategory) {
    final params = GameListParams(
      game: subCategory.gamecode ?? '',
      code: category.code ?? '',
      size: 30,
    );
    
    // 获取 provider 状态
    final gameState = ref.watch(gameListProvider(params));
    
    // 获取当前一级分类下的所有二级分类，用于顶部导航
    final subCategoriesAsync = ref.watch(subCategoriesProvider(category.code ?? ''));
    
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
        // 顶部二级分类切换导航 (任务二)
        subCategoriesAsync.when(
          data: (subCategories) => Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subCategories.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final item = subCategories[index];
                final isSelected = item.gamecode == subCategory.gamecode;
                
                String imageUrl = item.h5Logo ?? item.img ?? '';
                if (imageUrl.startsWith('/')) {
                  imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
                }

                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      setState(() {
                        _selectedSubCategory = item;
                        _selectedSubTabIndex = 0; // 切换分类时重置为“全部游戏”
                      });
                    }
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.white.withOpacity(0.1),
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
                            ),
                          )
                        else
                          const Icon(Icons.gamepad, size: 24, color: AppTheme.textTertiary),
                        const SizedBox(height: 4),
                        Text(
                          item.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
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

        const Divider(height: 1, color: Colors.white10),

        // 搜索和子页签 (任务一)
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 返回按钮
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textSecondary, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedSubCategory = null;
                    _selectedSubTabIndex = 0;
                  });
                },
              ),
              // 搜索按钮
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 22),
                onPressed: () {
                  // TODO: 实现子游戏搜索
                },
              ),
              const SizedBox(width: 4),
              // 全部游戏 / 我的收藏 页签
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
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
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
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

  Widget _buildGameCard(GameItem game, GameListParams? params) {
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
                              if (params != null) {
                                ref.read(gameListProvider(params).notifier).toggleFavoriteLocal(game.id!);
                              }
                              
                              // 计算目标状态
                              final targetStatus = game.isFavorite ? 0 : 1;
                              final success = await ref.read(userProvider.notifier).toggleFavorite(game.id!, targetStatus);
                              
                              if (!success && params != null) {
                                // 如果失败，回退本地状态
                                ref.read(gameListProvider(params).notifier).toggleFavoriteLocal(game.id!);
                              }
                            }
                          },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(102),
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
