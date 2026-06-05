import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/game/game_models.dart';
import '../../models/home/home_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/game/game_provider.dart';
import '../../providers/system/system_provider.dart';
import '../../security/url_policy.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../utils/game_launch_error.dart';
import '../../utils/site_display.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/retry_empty_state.dart';
import '../../widgets/search_panel_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _appliedInitialCode = '';

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
        if (_applyInitialCodeIfNeeded()) return;
        _selectCategory(nextIndex);
      });
    }
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCode == widget.initialCode) return;
    _appliedInitialCode = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyInitialCodeIfNeeded();
    });
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

  bool _applyInitialCodeIfNeeded() {
    final code = widget.initialCode?.trim() ?? '';
    if (code.isEmpty || code == _appliedInitialCode) return false;
    final provider = context.read<GameProvider>();
    final categories = provider.categories;
    final index = categories.indexWhere((category) => category.code == code);
    if (index < 0) return false;
    _appliedInitialCode = code;
    if (_tabController.length > index) {
      _tabController.animateTo(index);
    }
    _selectCategory(index);
    return true;
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
                  ? _buildRefreshableProviderGrid(
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
                siteDomainDisplayText(siteConfig?.domain),
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
      child: Container(
        width: 28.w,
        height: 28.w,
        color: const Color(0xFFE4EFFF),
        alignment: Alignment.center,
        child: Icon(Icons.casino, size: 16.sp, color: AppColors.primary),
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
        dividerColor: Colors.transparent,
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
    final hasError = message?.trim().isNotEmpty == true;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 150.h),
        if (hasError)
          RetryEmptyState(
            message: message!.trim(),
            onRetry: () => context.read<GameProvider>().loadCategories(
                  refresh: true,
                ),
          )
        else
          Center(
            child: Text(
              'game.noGameCategory'.tr(),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildProviderEmptyState(GameProvider provider, String code) {
    final hasError = provider.error?.trim().isNotEmpty == true;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 150.h),
        if (hasError)
          RetryEmptyState(
            message: provider.error!.trim(),
            onRetry: () => provider.loadGamesByCode(
              code,
              refresh: true,
            ),
          )
        else
          Center(
            child: Text(
              'game.noGame'.tr(),
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
      ],
    );
  }

  Future<void> _refreshCurrentCategory(GameProvider provider) async {
    await provider.loadCategories(refresh: true);
    final categories = provider.categories;
    if (categories.isEmpty) return;
    final index = _selectedTabIndex.clamp(0, categories.length - 1);
    _selectedTabIndex = index;
    await provider.loadGamesByCode(categories[index].code, refresh: true);
  }

  Widget _buildRefreshableProviderGrid(
    GameProvider provider,
    GameLobbyCategory category,
  ) {
    return RefreshIndicator(
      onRefresh: () => _refreshCurrentCategory(provider),
      child: _buildProviderGrid(provider, category),
    );
  }

  Widget _buildProviderGrid(GameProvider provider, GameLobbyCategory category) {
    if (provider.isCategoryLoading(category.code) && category.games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final games = category.games;
    if (games.isEmpty) {
      return _buildProviderEmptyState(provider, category.code);
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
        childAspectRatio: 0.62,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GameProviderGridCard(
          game: game,
          isLaunching: provider.launchingGameId == game.id,
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
          SnackBar(
            content: Text(
              result.message?.trim().isNotEmpty == true
                  ? result.message!.trim()
                  : 'game.enterFailed'.tr(),
            ),
          ),
        );
        return;
      }
      if (UrlPolicy.gameUri(urlText) == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('game.invalidUrl'.tr())),
        );
        return;
      }
      if (result.nesting == false) {
        final opened = await UrlPolicy.launchExternal(
          urlText,
          type: ExternalUrlType.game,
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
      messenger.showSnackBar(
        SnackBar(
          content: Text(gameLaunchErrorText(error, 'game.enterFailed')),
        ),
      );
    }
  }
}

class GameProviderGridCard extends StatelessWidget {
  const GameProviderGridCard({
    super.key,
    required this.game,
    required this.isLaunching,
    required this.onTap,
  });

  final GameProviderItem game;
  final bool isLaunching;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: ColoredBox(
                color: const Color(0xFFE6EFFA),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _GameProviderCover(logoUrl: game.logo),
                    if (isLaunching) const _GameProviderLaunchingOverlay(),
                    if (game.isMaintaining)
                      const _GameProviderMaintainingOverlay(),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            game.title,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1F1F1F),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GameProviderCover extends StatelessWidget {
  const _GameProviderCover({this.logoUrl});

  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = _buildFallback(context);
    if (logoUrl == null || logoUrl!.trim().isEmpty) return fallback;
    return LayoutBuilder(
      builder: (context, constraints) {
        return AppNetworkImage(
          key: ValueKey(logoUrl!.trim()),
          url: logoUrl!,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          fit: BoxFit.contain,
          optimize: false,
          errorWidget: fallback,
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      color: const Color(0xFFEFF3F8),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 30.sp,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _GameProviderLaunchingOverlay extends StatelessWidget {
  const _GameProviderLaunchingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _GameProviderMaintainingOverlay extends StatelessWidget {
  const _GameProviderMaintainingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
