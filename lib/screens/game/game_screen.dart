import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/game/game_models.dart';
import '../../models/home/home_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/game/game_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/search_panel_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

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
              return _buildSiteBrand(siteConfig, context);
            },
          ),
          GestureDetector(
            onTap: () => showSearchPanel(context),
            child: Icon(
              Icons.search,
              size: 24.sp,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteBrand(SiteConfig? siteConfig, BuildContext context) {
    return Row(
      children: [
        _buildSiteLogo(siteConfig?.logo),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _siteText(siteConfig?.title,
                  fallback: 'home.siteFallbackName'.tr()),
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
        message?.trim().isNotEmpty == true
            ? message!.trim()
            : 'game.noGameCategory'.tr(),
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
          'game.noGame'.tr(),
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
            _launchGame(game.launchTarget);
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
                        if (provider.launchingGameId == game.id)
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
                                  'game.launching'.tr(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (game.isMaintaining)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Text(
                              'game.maintaining'.tr(),
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

  Future<void> _launchGame(GameLaunchTarget target) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) {
      context.push('/login');
      return;
    }

    try {
      final result = await context.read<GameProvider>().launchGame(target);
      if (!mounted) return;
      final urlText = result.url?.trim();
      if (urlText == null || urlText.isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text('game.enterFailed'.tr())),
        );
        return;
      }
      if (Uri.tryParse(urlText) == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('game.invalidUrl'.tr())),
        );
        return;
      }
      if (result.nesting == false) {
        final opened = await launchUrl(
          Uri.parse(urlText),
          mode: LaunchMode.externalApplication,
        );
        if (!opened && mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('game.openFailed'.tr())),
          );
        }
        return;
      }
      context.push('/game-view', extra: {
        'url': urlText,
        'title': target.title,
      });
    } catch (error) {
      if (!mounted) return;
      final message = context.read<GameProvider>().launchError;
      messenger.showSnackBar(
        SnackBar(
            content: Text(message?.trim().isNotEmpty == true
                ? message!
                : 'game.enterFailed'.tr())),
      );
    }
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
}
