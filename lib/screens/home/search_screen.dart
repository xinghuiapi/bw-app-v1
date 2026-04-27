import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/models/home/home_data.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/services/game/game_service.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/providers/game/game_launcher_provider.dart';
import 'package:my_flutter_app/providers/game/hot_games_provider.dart';
import 'package:my_flutter_app/providers/home/search_provider.dart';
import 'package:my_flutter_app/providers/game/favorite_games_provider.dart';
import 'package:my_flutter_app/providers/auth/auth_provider.dart';
import 'package:my_flutter_app/providers/user/user_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/state_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  late ScrollController _scrollController;
  List<String> _recentSearches = [];
  static const String _historyKey = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 1,
    ); // 初始选中全部热门
    _tabController.addListener(_handleTabChange);
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        setState(() {
          _recentSearches = List<String>.from(json.decode(historyJson));
        });
      }
    } catch (e) {
      debugPrint('Load history failed: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, json.encode(_recentSearches));
    } catch (e) {
      debugPrint('Save history failed: $e');
    }
  }

  Future<void> _clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      setState(() {
        _recentSearches.clear();
      });
    } catch (e) {
      debugPrint('Clear history failed: $e');
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging && _tabController.index == 3) {
      // 切换到收藏页时，如果已登录则刷新数据
      if (ref.read(authProvider).isLoggedIn) {
        ref.read(favoriteGamesProvider.notifier).refresh();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_tabController.index == 0) {
        // 搜索结果分页
        final keyword = _controller.text.trim();
        if (keyword.isNotEmpty) {
          ref.read(searchGamesProvider.notifier).loadMore(keyword);
        }
      } else if (_tabController.index == 1) {
        // 热门游戏分页
        ref.read(hotGamesProvider.notifier).loadMore();
      } else if (_tabController.index == 3) {
        // 收藏游戏分页
        ref.read(favoriteGamesProvider.notifier).loadMore();
      }
    }
  }

  Future<void> _handleSearch() async {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    if (!_recentSearches.contains(keyword)) {
      setState(() {
        _recentSearches.insert(0, keyword);
        // Limit history size to 10
        if (_recentSearches.length > 10) {
          _recentSearches = _recentSearches.sublist(0, 10);
        }
      });
      _saveHistory();
    } else {
      // Move to top if already exists
      setState(() {
        _recentSearches.remove(keyword);
        _recentSearches.insert(0, keyword);
      });
      _saveHistory();
    }

    _tabController.animateTo(0); // 搜索后跳转到结果页
    ref.read(searchGamesProvider.notifier).search(keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackgroundColor(context),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.getPrimaryTextColor(context),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          '搜索',
          style: TextStyle(
            color: AppTheme.getPrimaryTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.getInputFillColor(context),
                borderRadius: BorderRadius.circular(24),
                // Removed BoxShadow for web optimization
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                textInputAction: TextInputAction.search, // 明确指定为搜索动作
                decoration: InputDecoration(
                  hintText: '搜索',
                  hintStyle: TextStyle(
                    color: AppTheme.getTertiaryTextColor(context),
                  ),
                  prefixIcon: null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: AppTheme.getTertiaryTextColor(context),
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus(); // 收起键盘
                      _handleSearch();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) {
                  FocusScope.of(context).unfocus(); // 收起键盘
                  _handleSearch();
                },
              ),
            ),
          ),

          // 最近搜索
          if (_recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '最近搜索',
                        style: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _clearHistory,
                        child: Text(
                          '清空',
                          style: TextStyle(
                            color: AppTheme.getTertiaryTextColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: _recentSearches
                        .map((tag) => _buildSearchTag(tag))
                        .toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.getTertiaryTextColor(context),
            indicatorColor: AppTheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16),
                    SizedBox(width: 4),
                    Text('搜索结果'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.whatshot, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('全部热门'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 16),
                    SizedBox(width: 4),
                    Text('最近游戏'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('我的收藏'),
                  ],
                ),
              ),
            ],
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchResults(),
                _buildHotGames(),
                const Center(child: Text('暂无最近游戏')),
                _buildFavoriteGames(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _handleSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.getInputFillColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.getDividerColor(context)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.getSecondaryTextColor(context),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchState = ref.watch(searchGamesProvider);

    if (searchState.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (searchState.error != null)
      return Center(
        child: Text(
          searchState.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    if (searchState.items.isEmpty) return const Center(child: Text('没有找到相关游戏'));

    return _buildGameGrid(searchState.items, searchState.isMoreLoading);
  }

  Widget _buildHotGames() {
    final hotGamesState = ref.watch(hotGamesProvider);

    if (hotGamesState.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (hotGamesState.error != null)
      return ErrorStateWidget(
        message: '加载失败: ${hotGamesState.error}',
        onRetry: () => ref.read(hotGamesProvider.notifier).refresh(),
      );
    if (hotGamesState.items.isEmpty) return const Center(child: Text('暂无热门游戏'));

    return _buildGameGrid(hotGamesState.items, hotGamesState.isMoreLoading);
  }

  Widget _buildFavoriteGames() {
    if (!ref.watch(authProvider).isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('请先登录以查看收藏游戏', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('去登录', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final favoriteGamesState = ref.watch(favoriteGamesProvider);

    if (favoriteGamesState.isLoading)
      return const Center(child: CircularProgressIndicator());
    if (favoriteGamesState.error != null)
      return ErrorStateWidget(
        message: '加载失败: ${favoriteGamesState.error}',
        onRetry: () => ref.read(favoriteGamesProvider.notifier).refresh(),
      );
    if (favoriteGamesState.items.isEmpty)
      return const Center(child: Text('暂无收藏游戏'));

    return _buildGameGrid(
      favoriteGamesState.items,
      favoriteGamesState.isMoreLoading,
    );
  }

  Widget _buildGameGrid(List<GameItem> games, bool isMoreLoading) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: games.length,
            // 优化性能，使用 findChildIndexCallback 避免不必要的重建
            findChildIndexCallback: (Key key) {
              final ValueKey<String> valueKey = key as ValueKey<String>;
              final String id = valueKey.value;
              final index = games.indexWhere((game) => game.id?.toString() == id);
              return index >= 0 ? index : null;
            },
            itemBuilder: (context, index) {
              return KeyedSubtree(
                key: ValueKey(games[index].id?.toString() ?? index.toString()),
                child: _buildGameCard(games[index]),
              );
            },
          ),
        ),
        if (isMoreLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameCard(GameItem game) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String imageUrl = game.img ?? '';
    if (imageUrl.startsWith('/')) {
      imageUrl = '${AppConstants.resourceBaseUrl}$imageUrl';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        ref
            .read(gameLauncherProvider)
            .launchGame(
              context,
              game,
              isCategoryResult: game.isCategoryResult ?? false,
              isHot: game.isHot ?? false,
            );
      },
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: WebSafeImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // 平台标签与收藏移至下方，避免使用 Stack 叠加 DOM
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (game.interfaceTitle != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            game.interfaceTitle!,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (game.id != null) {
                            // 检查登录状态
                            if (!ref.read(authProvider).isLoggedIn) {
                              ToastUtils.showInfo('请先登录以收藏游戏');
                              return;
                            }

                            // 本地先切换，提供即时反馈
                            if (_tabController.index == 0) {
                              ref
                                  .read(searchGamesProvider.notifier)
                                  .toggleFavoriteLocal(game.id!);
                            } else if (_tabController.index == 1) {
                              ref
                                  .read(hotGamesProvider.notifier)
                                  .toggleFavoriteLocal(game.id!);
                            } else if (_tabController.index == 3) {
                              ref
                                  .read(favoriteGamesProvider.notifier)
                                  .toggleFavoriteLocal(game.id!);
                            }

                            // 计算目标状态
                            final targetStatus = game.isFavorite ? 0 : 1;
                            final success = await ref
                                .read(userProvider.notifier)
                                .toggleFavorite(game.id!, targetStatus);

                            if (!success) {
                              // 如果失败，回退本地状态
                              if (_tabController.index == 0) {
                                ref
                                    .read(searchGamesProvider.notifier)
                                    .toggleFavoriteLocal(game.id!);
                              } else if (_tabController.index == 1) {
                                ref
                                    .read(hotGamesProvider.notifier)
                                    .toggleFavoriteLocal(game.id!);
                              } else if (_tabController.index == 3) {
                                // 在收藏页如果是失败了，其实应该刷新一下或者重新添加回来
                                // 这里简单处理为刷新
                                ref
                                    .read(favoriteGamesProvider.notifier)
                                    .refresh();
                              }
                            } else {
                              ToastUtils.showSuccess(
                                targetStatus == 1 ? '已加入收藏' : '已取消收藏',
                              );
                              // 成功后，如果是从其他页面收藏/取消，可能需要同步收藏页
                              if (_tabController.index != 3) {
                                ref
                                    .read(favoriteGamesProvider.notifier)
                                    .refresh();
                              }
                            }
                          }
                        },
                        child: Icon(
                          game.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: game.isFavorite
                              ? AppTheme.primary
                              : AppTheme.getTertiaryTextColor(context),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            game.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
