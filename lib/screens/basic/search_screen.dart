import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/utils/constants.dart';
import 'package:my_flutter_app/services/game_service.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';
import 'package:my_flutter_app/providers/game_launcher_provider.dart';
import 'package:my_flutter_app/providers/hot_games_provider.dart';
import 'package:my_flutter_app/providers/search_provider.dart';
import 'package:my_flutter_app/providers/favorite_games_provider.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import 'package:my_flutter_app/providers/user_provider.dart';
import 'package:my_flutter_app/utils/toast_utils.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  late ScrollController _scrollController;
  List<String> _recentSearches = ['王者']; // 模拟最近搜索

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1); // 初始选中全部热门
    _tabController.addListener(_handleTabChange);
    _scrollController = ScrollController()..addListener(_onScroll);
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
      });
    }

    _tabController.animateTo(0); // 搜索后跳转到结果页
    ref.read(searchGamesProvider.notifier).search(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.background : const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('搜索', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
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
                color: isDark ? AppTheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: '搜索',
                  hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
                  prefixIcon: null,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: isDark ? AppTheme.primary : Colors.grey),
                    onPressed: _handleSearch,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _handleSearch(),
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
                      Text('最近搜索', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => setState(() => _recentSearches.clear()),
                        child: Text('清空', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: _recentSearches.map((tag) => _buildSearchTag(tag)).toList(),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
            indicatorColor: AppTheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _handleSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Text(text, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 12)),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchState = ref.watch(searchGamesProvider);
    
    if (searchState.isLoading) return const Center(child: CircularProgressIndicator());
    if (searchState.error != null) return Center(child: Text(searchState.error!, style: const TextStyle(color: Colors.red)));
    if (searchState.items.isEmpty) return const Center(child: Text('没有找到相关游戏'));

    return _buildGameGrid(searchState.items, searchState.isMoreLoading);
  }

  Widget _buildHotGames() {
    final hotGamesState = ref.watch(hotGamesProvider);

    if (hotGamesState.isLoading) return const Center(child: CircularProgressIndicator());
    if (hotGamesState.error != null) return Center(child: Text('加载失败: ${hotGamesState.error}'));
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('去登录', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final favoriteGamesState = ref.watch(favoriteGamesProvider);

    if (favoriteGamesState.isLoading) return const Center(child: CircularProgressIndicator());
    if (favoriteGamesState.error != null) return Center(child: Text('加载失败: ${favoriteGamesState.error}'));
    if (favoriteGamesState.items.isEmpty) return const Center(child: Text('暂无收藏游戏'));

    return _buildGameGrid(favoriteGamesState.items, favoriteGamesState.isMoreLoading);
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
            itemBuilder: (context, index) {
              return _buildGameCard(games[index]);
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
      onTap: () {
        ref.read(gameLauncherProvider).launchGame(
              context,
              game,
              isCategoryResult: game.isCategoryResult ?? false,
              isHot: game.isHot ?? false,
            );
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: WebSafeImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // 收藏按钮
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () async {
                      if (game.id != null) {
                        // 检查登录状态
                        if (!ref.read(authProvider).isLoggedIn) {
                          ToastUtils.showInfo('请先登录以收藏游戏');
                          return;
                        }

                        // 本地先切换，提供即时反馈
                        if (_tabController.index == 0) {
                          ref.read(searchGamesProvider.notifier).toggleFavoriteLocal(game.id!);
                        } else if (_tabController.index == 1) {
                          ref.read(hotGamesProvider.notifier).toggleFavoriteLocal(game.id!);
                        } else if (_tabController.index == 3) {
                          ref.read(favoriteGamesProvider.notifier).toggleFavoriteLocal(game.id!);
                        }
                        
                        // 计算目标状态
                        final targetStatus = game.isFavorite ? 0 : 1;
                        final success = await ref.read(userProvider.notifier).toggleFavorite(game.id!, targetStatus);
                        
                        if (!success) {
                          // 如果失败，回退本地状态
                          if (_tabController.index == 0) {
                            ref.read(searchGamesProvider.notifier).toggleFavoriteLocal(game.id!);
                          } else if (_tabController.index == 1) {
                            ref.read(hotGamesProvider.notifier).toggleFavoriteLocal(game.id!);
                          } else if (_tabController.index == 3) {
                            // 在收藏页如果是失败了，其实应该刷新一下或者重新添加回来
                            // 这里简单处理为刷新
                            ref.read(favoriteGamesProvider.notifier).refresh();
                          }
                        } else {
                          ToastUtils.showSuccess(targetStatus == 1 ? '已加入收藏' : '已取消收藏');
                          // 成功后，如果是从其他页面收藏/取消，可能需要同步收藏页
                          if (_tabController.index != 3) {
                            ref.read(favoriteGamesProvider.notifier).refresh();
                          }
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
                        size: 18,
                      ),
                    ),
                  ),
                ),
                // 平台标签
                if (game.interfaceTitle != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        game.interfaceTitle!,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
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
