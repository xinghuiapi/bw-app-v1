import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/game/game_models.dart';
import '../../models/home/home_models.dart';
import '../../providers/game/game_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/custom_tab_bar.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'lottery', 'name': '彩票'},
    {'id': 'live', 'name': '视讯'},
    {'id': 'game', 'name': '电子'},
    {'id': 'fishing', 'name': '捕鱼'},
    {'id': 'sport', 'name': '体育'},
    {'id': 'poker', 'name': '棋牌'},
    {'id': 'esports', 'name': '电竞'},
  ];

  final List<Map<String, dynamic>> _games = [
    {
      'title': 'PA视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'PA视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'BBIN视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'DG视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': '欧博视讯',
      'image': AppImages.zr,
      'maintaining': true,
      'loading': false
    },
    {
      'title': 'DB视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': '完美视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
    {
      'title': 'SEXY视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': true
    },
    {
      'title': 'BG视讯',
      'image': AppImages.zr,
      'maintaining': false,
      'loading': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabController.addListener(_handleTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameProvider>().loadCategories();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final remoteLength = context.watch<GameProvider>().categories.length;
    final targetLength = remoteLength == 0 ? 1 : remoteLength;
    if (_tabController.length == targetLength) return;
    final nextIndex = _selectedTabIndex.clamp(0, targetLength - 1);
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _tabController = TabController(
      length: targetLength,
      vsync: this,
      initialIndex: nextIndex,
    );
    _selectedTabIndex = nextIndex;
    _tabController.addListener(_handleTabChanged);
    if (remoteLength > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _selectCategory(nextIndex);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    _selectCategory(_tabController.index);
  }

  void _selectCategory(int index) {
    if (_selectedTabIndex != index) {
      setState(() => _selectedTabIndex = index);
    }
    final provider = context.read<GameProvider>();
    final categories = provider.categories;
    if (categories.isEmpty || index >= categories.length) return;
    final category = categories[index];
    if (provider.hasCategoryLoaded(category.code) ||
        provider.isCategoryLoading(category.code)) {
      return;
    }
    provider.loadGamesByCode(category.code);
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final remoteCategories = gameProvider.categories;
    final hasRemoteCategories = remoteCategories.isNotEmpty;
    final isWaitingForCategories = !hasRemoteCategories &&
        gameProvider.isLoading &&
        gameProvider.error == null;
    final selectedIndex = _selectedTabIndex.clamp(
      0,
      (hasRemoteCategories ? remoteCategories.length : 1) - 1,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            if (hasRemoteCategories) _buildTabs(gameProvider),
            Expanded(
              child: hasRemoteCategories
                  ? _buildProviderGrid(
                      gameProvider,
                      remoteCategories[selectedIndex],
                    )
                  : isWaitingForCategories
                      ? const Center(child: CircularProgressIndicator())
                      : _buildEmptyState(gameProvider.error),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomTabBar(
        currentIndex: 1,
        onChanged: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.read<GameProvider>().loadCategories(refresh: true);
              break;
            case 2:
              context.go('/activity');
              break;
            case 3:
              context.go('/service');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: [
          CustomTabBarItem(
            label: '首页',
            icon: Icon(Icons.home_outlined, size: 24.sp),
            activeIcon: Icon(Icons.home, size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '游戏大厅',
            icon: Icon(Icons.videogame_asset_outlined, size: 24.sp),
            activeIcon: Icon(Icons.videogame_asset,
                size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '活动',
            icon: Icon(Icons.card_giftcard_outlined, size: 24.sp),
            activeIcon: Icon(Icons.card_giftcard,
                size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '客服',
            icon: Icon(Icons.headset_mic_outlined, size: 24.sp),
            activeIcon:
                Icon(Icons.headset_mic, size: 24.sp, color: AppColors.primary),
          ),
          CustomTabBarItem(
            label: '我的',
            icon: Icon(Icons.person_outline, size: 24.sp),
            activeIcon:
                Icon(Icons.person, size: 24.sp, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Selector<SystemProvider, SiteConfig?>(
            selector: (_, provider) => provider.config.siteConfig,
            builder: (context, siteConfig, child) {
              return _buildSiteBrand(siteConfig);
            },
          ),
          Icon(Icons.search, size: 24.sp, color: const Color(0xFF333333)),
        ],
      ),
    );
  }

  Widget _buildSiteBrand(SiteConfig? siteConfig) {
    return Row(
      children: [
        _buildSiteLogo(siteConfig?.logo),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _siteText(siteConfig?.title, fallback: '星汇演示'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Transform.scale(
              scale: 0.9,
              alignment: Alignment.centerLeft,
              child: Text(
                _siteText(siteConfig?.domain, fallback: 'xh-bet.com'),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSiteLogo(String? logoUrl) {
    final fallback = ClipOval(
      child: Image.asset(
        AppImages.hero,
        width: 28.w,
        height: 28.w,
        fit: BoxFit.cover,
      ),
    );
    if (logoUrl == null || logoUrl.trim().isEmpty) return fallback;

    return AppNetworkImage(
      url: logoUrl,
      width: 28.w,
      height: 28.w,
      borderRadius: BorderRadius.circular(14.r),
      errorWidget: fallback,
    );
  }

  String _siteText(String? value, {required String fallback}) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  Widget _buildTabs(GameProvider gameProvider) {
    final remoteCategories = gameProvider.categories;
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.label,
        onTap: _selectCategory,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
        tabs: remoteCategories.map((cat) => Tab(text: cat.title)).toList(),
      ),
    );
  }

  Widget _buildEmptyState(String? message) {
    return Center(
      child: Text(
        message?.trim().isNotEmpty == true ? message!.trim() : '暂无游戏分类',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
      ),
    );
  }

  Widget _buildProviderGrid(GameProvider provider, GameLobbyCategory category) {
    if (provider.isCategoryLoading(category.code) && category.games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final games = category.games;
    if (games.isEmpty) {
      return Center(
        child: Text(
          '暂无游戏',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      );
    }

    return GridView.builder(
      padding:
          EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: games.length <= 1
            ? 1
            : games.length == 2
                ? 2
                : 3,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GestureDetector(
          onTap: () {
            if (game.isMaintaining) return;
            if (game.opensSubList) {
              context.push(
                '/game-sub?code=${Uri.encodeComponent(category.code)}&game=${Uri.encodeComponent(game.code)}&title=${Uri.encodeComponent(game.title)}',
              );
              return;
            }
            context.push('/login');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildProviderCover(game.logo, games.length),
                        if (game.isMaintaining)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Text(
                              '维护中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  alignment: Alignment.center,
                  child: Text(
                    game.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1F1F1F),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderCover(String? logoUrl, int itemCount) {
    final fallback = Image.asset(
      AppImages.zr,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );
    if (logoUrl == null || logoUrl.trim().isEmpty) return fallback;
    final crossAxisCount = itemCount <= 1
        ? 1
        : itemCount == 2
            ? 2
            : 3;
    final cardWidth =
        (1.sw - 24.w - (crossAxisCount - 1) * 12.w) / crossAxisCount;
    return AppNetworkImage(
      url: logoUrl,
      width: cardWidth,
      height: cardWidth / 0.72,
      errorWidget: fallback,
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      padding:
          EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: 24.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72, // Adjust to fit cover and title nicely
      ),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        final isMaintaining = game['maintaining'] as bool;
        final isLoading = game['loading'] as bool;

        return GestureDetector(
          onTap: () {
            if (isMaintaining || isLoading) return;
            // Simulated game entry or sublist
            context.push('/game-sub');
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          game['image'] as String,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                        if (isMaintaining)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Text(
                              '维护中',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (isLoading && !isMaintaining)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 24.w,
                                  height: 24.w,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  '加载中...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  alignment: Alignment.center,
                  child: Text(
                    game['title'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1F1F1F),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
