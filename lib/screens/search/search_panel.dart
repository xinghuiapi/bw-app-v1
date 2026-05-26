import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/game/game_models.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/game/game_provider.dart';
import '../../security/url_policy.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/app_network_image.dart';
import '../../widgets/common/back_hit_target.dart';
import '../../widgets/search_input.dart';

class SearchPanel extends StatefulWidget {
  const SearchPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel>
    with SingleTickerProviderStateMixin {
  static const _historyKey = 'm1_search_history';

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;
  List<String> _history = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabChanged);
    _scrollController.addListener(_handleScroll);
    _readHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameProvider>().loadSearchGames(label: 'hot');
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging) return;
    _runActiveTabQuery();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 160.h) return;
    final provider = context.read<GameProvider>();
    if (_tabController.index == 2) return;
    provider.loadMoreSearchGames();
  }

  Future<void> _readHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _history = prefs.getStringList(_historyKey) ?? const []);
  }

  Future<void> _writeHistory(List<String> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, history);
  }

  Future<void> _addHistory(String value) async {
    final word = value.trim();
    if (word.isEmpty) return;
    final next = <String>[
      word,
      ..._history.where((item) => item != word),
    ].take(15).toList();
    setState(() => _history = next);
    await _writeHistory(next);
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (!mounted) return;
    setState(() => _history = const []);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      if (value.trim().isNotEmpty && _tabController.index == 1) {
        _tabController.animateTo(0);
        return;
      }
      _runActiveTabQuery(auto: true);
    });
  }

  void _runActiveTabQuery({bool auto = false}) {
    final provider = context.read<GameProvider>();
    final word = _searchController.text.trim();
    switch (_tabController.index) {
      case 1:
        provider.loadSearchGames(label: 'hot');
        break;
      case 2:
        if (!context.read<AuthProvider>().isAuthenticated) return;
        provider.loadFavoriteGames(refresh: true);
        break;
      default:
        if (word.isEmpty) {
          provider.loadSearchGames();
          return;
        }
        if (!auto) _addHistory(word);
        provider.loadSearchGames(searchWord: word);
    }
  }

  void _submitSearch() {
    if (_tabController.index == 2) return;
    if (_tabController.index == 1) {
      _tabController.animateTo(0);
      return;
    }
    _runActiveTabQuery();
  }

  void _selectHistory(String word) {
    _searchController.text = word;
    _searchController.selection = TextSelection.collapsed(offset: word.length);
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
      return;
    }
    _submitSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: Consumer<GameProvider>(
                builder: (context, provider, child) {
                  return IndexedStack(
                    index: _tabController.index,
                    children: [
                      _buildSearchContent(provider, showHistory: true),
                      _buildSearchContent(provider),
                      _buildFavoriteContent(provider),
                    ],
                  );
                },
              ),
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
        children: [
          BackHitTarget(
            icon: Icons.arrow_back_ios,
            iconSize: 20.sp,
            color: AppColors.textPrimary,
            onTap: widget.onClose,
          ),
          Expanded(
            child: SearchInput(
              controller: _searchController,
              hintText: 'search.hint'.tr(),
              autoFocus: true,
              onChanged: _onSearchChanged,
              onSearch: _submitSearch,
              onClear: () => context.read<GameProvider>().loadSearchGames(),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
            onTap: _submitSearch,
            child: Text(
              'common.search'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        unselectedLabelStyle:
            TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3.h,
        dividerColor: Colors.transparent,
        tabAlignment: TabAlignment.fill,
        onTap: (_) => _runActiveTabQuery(),
        tabs: [
          Tab(text: 'game.all'.tr()),
          Tab(text: 'game.hotGames'.tr()),
          Tab(text: 'game.favorites'.tr()),
        ],
      ),
    );
  }

  Widget _buildSearchContent(GameProvider provider,
      {bool showHistory = false}) {
    final word = _searchController.text.trim();
    final canShowHistory = showHistory && word.isEmpty && _history.isNotEmpty;
    final isLoading =
        provider.isSearchLoading && provider.searchPage.data.isEmpty;
    final games = provider.searchPage.data;

    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView(
      controller: showHistory ? _scrollController : null,
      padding: EdgeInsets.all(16.w),
      children: [
        if (canShowHistory) _buildHistorySection(),
        if (games.isNotEmpty) _buildGameGrid(games),
        if (games.isEmpty && !canShowHistory && provider.hasSearchLoaded)
          _buildEmpty('game.noGame'.tr()),
        if (provider.searchError?.trim().isNotEmpty == true)
          _buildEmpty(provider.searchError!.trim()),
        if (provider.isSearchLoadingMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildFavoriteContent(GameProvider provider) {
    final isLoggedIn = context.watch<AuthProvider>().isAuthenticated;
    if (!isLoggedIn) return _buildEmpty('game.favoriteLogin'.tr());
    if (provider.isFavoriteGamesLoading && provider.favoriteGames.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.favoriteGames.isEmpty && provider.hasFavoriteGamesLoaded) {
      return _buildEmpty('game.noFavoriteGame'.tr());
    }
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (provider.favoriteGames.isNotEmpty)
          _buildGameGrid(provider.favoriteGames),
        if (provider.favoriteGamesError?.trim().isNotEmpty == true)
          _buildEmpty(provider.favoriteGamesError!.trim()),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 18.sp, color: AppColors.textSecondary),
                  SizedBox(width: 4.w),
                  Text(
                    'common.history'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _clearHistory,
                child: Icon(Icons.delete_outline,
                    size: 18.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: _history
                .map(
                  (item) => GestureDetector(
                    onTap: () => _selectHistory(item),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid(List<GameItem> games) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: games.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) => _GameCard(
        game: games[index],
        onTap: () => _launchGame(games[index]),
        onFavorite: () => _toggleFavorite(games[index]),
      ),
    );
  }

  Widget _buildEmpty(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(GameItem game) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) {
      messenger
          .showSnackBar(SnackBar(content: Text('game.favoriteLogin'.tr())));
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
              : 'game.unfavoriteSuccess'.tr()),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(game.isFavorite
              ? 'game.unfavoriteFailed'.tr()
              : 'game.favoriteFailed'.tr()),
        ),
      );
    }
  }

  Future<void> _launchGame(GameItem game) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!context.read<AuthProvider>().isAuthenticated) {
      widget.onClose();
      context.push('/login');
      return;
    }
    if (game.isMaintaining) return;
    try {
      final result = await context.read<GameProvider>().launchGame(
            GameLaunchTarget(id: game.id, title: game.title ?? ''),
          );
      if (!mounted) return;
      final urlText = result.url?.trim();
      if (urlText == null || urlText.isEmpty) {
        messenger
            .showSnackBar(SnackBar(content: Text('game.enterFailed'.tr())));
        return;
      }
      if (UrlPolicy.gameUri(urlText) == null) {
        messenger.showSnackBar(SnackBar(content: Text('game.invalidUrl'.tr())));
        return;
      }
      if (result.nesting == false) {
        final opened = await UrlPolicy.launchExternal(
          urlText,
          type: ExternalUrlType.game,
        );
        if (!opened && mounted) {
          messenger
              .showSnackBar(SnackBar(content: Text('game.openFailed'.tr())));
        }
        return;
      }
      widget.onClose();
      context.push('/game-view', extra: {
        'url': urlText,
        'title': game.title ?? '',
      });
    } catch (_) {
      if (!mounted) return;
      final message = context.read<GameProvider>().launchError;
      messenger.showSnackBar(
        SnackBar(
          content: Text(message?.trim().isNotEmpty == true
              ? message!
              : 'game.enterFailed'.tr()),
        ),
      );
    }
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onTap,
    required this.onFavorite,
  });

  final GameItem game;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final isLaunching = provider.launchingGameId == game.id;
    final isFavoriting = provider.favoritingGameId == game.id;
    return GestureDetector(
      onTap: isLaunching ? null : onTap,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EFFA),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppNetworkImage(
                    url: game.img,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: Icon(
                      Icons.videogame_asset_outlined,
                      size: 24.sp,
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: GestureDetector(
                    onTap: isFavoriting ? null : onFavorite,
                    child: Container(
                      width: 26.w,
                      height: 26.w,
                      decoration: BoxDecoration(
                        color: game.isFavorite
                            ? AppColors.primary.withValues(alpha: 0.9)
                            : Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                      ),
                      child: isFavoriting
                          ? Padding(
                              padding: EdgeInsets.all(6.w),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              game.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 15.sp,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                if (isLaunching)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 22.w,
                          height: 22.w,
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
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            game.title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
