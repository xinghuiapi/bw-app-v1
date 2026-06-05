import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/game/game_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/game/game_provider.dart';
import '../../security/url_policy.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_images.dart';
import '../../utils/game_launch_error.dart';
import '../../widgets/common/app_network_image.dart';

class GameSubListScreen extends StatefulWidget {
  const GameSubListScreen({super.key, this.code, this.game, this.title});

  final String? code;
  final String? game;
  final String? title;

  @override
  State<GameSubListScreen> createState() => _GameSubListScreenState();
}

class _GameSubListScreenState extends State<GameSubListScreen>
    with SingleTickerProviderStateMixin {
  static const int _remotePageSize = 24;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedTabIndex = 0;
  bool _showSearchBar = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameProvider>().loadGameSubList(
            code: widget.code ?? '',
            game: widget.game ?? '',
            size: _remotePageSize,
          );
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_selectedTabIndex == _tabController.index) return;
    setState(() => _selectedTabIndex = _tabController.index);
  }

  void _toggleSearchBar() {
    setState(() => _showSearchBar = !_showSearchBar);
    if (_showSearchBar) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    } else {
      _searchDebounce?.cancel();
      _searchController.clear();
      _loadRemoteSearch('');
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _loadRemoteSearch(value);
    });
  }

  void _loadRemoteSearch(String value) {
    if (!_hasRemoteParams) return;
    context.read<GameProvider>().loadGameSubList(
          code: widget.code ?? '',
          game: widget.game ?? '',
          size: _remotePageSize,
          searchWord: value,
        );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final remoteGames = gameProvider.subListPage.data;
    final expectsRemoteData = _hasRemoteParams;
    final isCurrentRemoteQuery = gameProvider.isCurrentSubList(
      code: widget.code ?? '',
      game: widget.game ?? '',
      searchWord: _searchController.text,
    );
    final hasRemoteState = expectsRemoteData &&
        isCurrentRemoteQuery &&
        (gameProvider.hasSubListLoaded || remoteGames.isNotEmpty);
    final isFavoriteTab = _selectedTabIndex == 1;
    final visibleRemoteGames = isFavoriteTab
        ? remoteGames.where((game) => game.isFavorite).toList()
        : remoteGames;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // 贴合截图的淡灰色背景
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0, // M3 取消滚动阴影
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.primary, size: 24.sp),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/game'),
        ),
        title: Text(
          _titleText(),
          style: TextStyle(
            color: const Color(0xFF1F1F1F),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showSearchBar ? Icons.search_off_rounded : Icons.search,
              color: AppColors.primary,
              size: 24.sp,
            ),
            onPressed: _toggleSearchBar,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar) _buildSearchBar(),
          _buildTabs(),
          Expanded(
            child: expectsRemoteData
                ? _buildRemoteGrid(
                    hasRemoteState ? visibleRemoteGames : const <GameItem>[],
                    gameProvider,
                    isFavoriteTab: isFavoriteTab,
                    isWaitingForCurrentQuery: !hasRemoteState,
                  )
                : _buildEmptyGrid(isFavoriteTab: isFavoriteTab),
          ),
        ],
      ),
    );
  }

  bool get _hasRemoteParams {
    return (widget.code ?? '').trim().isNotEmpty &&
        (widget.game ?? '').trim().isNotEmpty;
  }

  String _titleText() {
    final title = widget.title?.trim();
    return title == null || title.isEmpty ? 'game.listTitle'.tr() : title;
  }

  Widget _buildRemoteGrid(
    List<GameItem> games,
    GameProvider provider, {
    bool isFavoriteTab = false,
    bool isWaitingForCurrentQuery = false,
  }) {
    if ((isWaitingForCurrentQuery || provider.isSubListLoading) &&
        games.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (games.isEmpty) {
      return Center(
        child: Text(
          isFavoriteTab ? 'game.noFavoriteGame'.tr() : 'game.noGame'.tr(),
          style: TextStyle(color: const Color(0xFF999999), fontSize: 14.sp),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!isFavoriteTab && notification.metrics.extentAfter < 320) {
          provider.loadMoreGameSubList();
        }
        return false;
      },
      child: GridView.builder(
        cacheExtent: 320,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.65,
        ),
        itemCount: games.length + (provider.isSubListLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= games.length) {
            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return _buildRemoteGameCard(games[index]);
        },
      ),
    );
  }

  Widget _buildRemoteGameCard(GameItem game) {
    final provider = context.watch<GameProvider>();
    final isFavoriting = provider.favoritingGameId == game.id;
    final isLaunching = provider.launchingGameId == game.id;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          if (game.isMaintaining) return;
          _launchRemoteGame(game.launchTarget);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: _buildRemoteCover(game.img),
                  ),
                  if (isLaunching)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
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
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: GestureDetector(
                      onTap: isFavoriting
                          ? null
                          : () {
                              _toggleRemoteFavorite(game);
                            },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: game.isFavorite
                              ? AppColors.primary
                              : Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: isFavoriting
                            ? SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                game.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                      ),
                    ),
                  ),
                  if (game.isMaintaining)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
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
            SizedBox(height: 6.h),
            Text(
              game.title ?? '',
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF333333)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchRemoteGame(GameLaunchTarget target) async {
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

  Future<void> _toggleRemoteFavorite(GameItem game) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) {
      messenger.showSnackBar(
        SnackBar(content: Text('game.favoriteLogin'.tr())),
      );
      return;
    }
    try {
      final next = !game.isFavorite;
      await context.read<GameProvider>().toggleGameFavorite(game);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
            content: Text(next
                ? 'game.favoriteSuccess'.tr()
                : 'game.unfavoriteSuccess'.tr())),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
            content: Text(game.isFavorite
                ? 'game.unfavoriteFailed'.tr()
                : 'game.favoriteFailed'.tr())),
      );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20.sp, color: const Color(0xFF999999)),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onSubmitted: _loadRemoteSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'search.hint'.tr(),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF333333)),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchDebounce?.cancel();
                setState(() => _searchController.clear());
                _loadRemoteSearch('');
              },
              child: Icon(Icons.cancel,
                  size: 18.sp, color: const Color(0xFFCCCCCC)),
            ),
        ],
      ),
    );
  }

  Widget _buildRemoteCover(String? imageUrl) {
    final fallback = _buildCoverFallback();
    if (imageUrl == null || imageUrl.trim().isEmpty) return fallback;
    final cardWidth = (1.sw - 32.w - 36.w) / 4;
    return AppNetworkImage(
      url: imageUrl,
      width: cardWidth,
      height: cardWidth,
      optimize: false,
      errorWidget: fallback,
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      color: const Color(0xFFEFF3F8),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 24.sp,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, top: 12.h, bottom: 8.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r), // 截图中的大圆角
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3.h,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: const Color(0xFF333333),
        unselectedLabelColor: const Color(0xFF999999),
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            TextStyle(fontSize: 15.sp, fontWeight: FontWeight.normal),
        dividerColor: Colors.transparent, // 去除 M3 默认底部分割线
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(text: 'game.all'.tr()),
          Tab(text: 'game.favorites'.tr()),
        ],
      ),
    );
  }

  Widget _buildEmptyGrid({bool isFavoriteTab = false}) {
    return Center(
      child: Text(
        isFavoriteTab ? 'game.noFavoriteGame'.tr() : 'game.noGame'.tr(),
        style: TextStyle(color: const Color(0xFF999999), fontSize: 14.sp),
      ),
    );
  }
}
