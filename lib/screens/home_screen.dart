import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;
import '../models/game/game_models.dart';
import '../models/home/home_models.dart';
import '../localization/app_language.dart';
import '../providers/localization/language_provider.dart';
import '../providers/auth/auth_provider.dart';
import '../providers/activity/activity_provider.dart';
import '../providers/feedback/feedback_provider.dart';
import '../providers/game/game_management_provider.dart';
import '../providers/game/game_provider.dart';
import '../providers/message/message_provider.dart';
import '../providers/record/record_provider.dart';
import '../providers/system/system_provider.dart';
import '../providers/user/user_provider.dart';
import '../providers/wallet/wallet_provider.dart';
import '../security/url_policy.dart';
import '../theme/app_colors.dart';
import '../theme/app_images.dart';
import '../widgets/common/app_network_image.dart';
import '../widgets/common/retry_empty_state.dart';
import '../widgets/home_user_action_card.dart';
import '../widgets/notice_bar.dart';
import '../widgets/search_panel_overlay.dart';
import '../utils/version_utils.dart';

GameLobbyCategory? homeCategoryOrNull(
  List<GameLobbyCategory> categories,
  String code,
) {
  final normalizedCode = code.trim();
  for (final category in categories) {
    if (category.code == normalizedCode) return category;
  }
  return null;
}

void navigateToServiceTab(BuildContext context) {
  context.go('/service');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class HomeLargeCategoryArtwork extends StatelessWidget {
  const HomeLargeCategoryArtwork({
    super.key,
    required this.image,
    required this.height,
    required this.borderRadius,
  });

  final String image;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Image.asset(
          image,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  static const _noticeSuppressDateKey = 'm1_notice_suppress_date';
  static const _updateSuppressVersionKey = 'm1_update_suppress_version';
  static const _fallbackLocalAppVersion = '1.0.0';

  bool _showBalance = true;
  bool _didTryOpenNotice = false;
  bool _didCompleteUpdateCheck = false;
  bool _isCheckingUpdate = false;
  bool _isUpdateDialogOpen = false;
  String _currentAppVersion = '';
  String _lastShownUpdateVersion = '';
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;
  List<GameLobbyCategory> _homeCategories = const [];

  double get _recoGameCardSize {
    final scaled = 100.w;
    if (scaled < 86) return 86;
    if (scaled > 120) return 120;
    return scaled;
  }

  double get _recoGameCardGap {
    final scaled = 12.w;
    if (scaled < 8) return 8;
    if (scaled > 12) return 12;
    return scaled;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final gameProvider = context.read<GameProvider>();
      _loadHomeCategories();
      gameProvider.loadRecommendedGames();
      gameProvider.loadHotGames();
      _loadCurrentAppVersion();
      _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted || !_bannerController.hasClients) return;
        final banners = _visibleBanners(
          context.read<SystemProvider>().config.banners,
          context.read<LanguageProvider>().currentCode,
        );
        if (banners.length <= 1) return;
        final next = (_bannerIndex + 1) % banners.length;
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final systemProvider = context.watch<SystemProvider>();
    _scheduleUpdateModal(systemProvider);
    _scheduleNoticeModal(systemProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: _buildHomeBody(),
    );
  }

  void _scheduleNoticeModal(SystemProvider systemProvider) {
    if (_didTryOpenNotice) return;
    if (!_didCompleteUpdateCheck || _isCheckingUpdate || _isUpdateDialogOpen)
      return;
    if (!systemProvider.hasLoadedConfig) return;
    final notices = _popupNotices(systemProvider.config.notices);
    if (notices.isEmpty) return;
    _didTryOpenNotice = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showNoticeModalIfAllowed(notices);
    });
  }

  void _scheduleUpdateModal(SystemProvider systemProvider) {
    if (_didCompleteUpdateCheck || _isCheckingUpdate || _isUpdateDialogOpen)
      return;
    if (!systemProvider.hasLoadedConfig) return;
    final site = systemProvider.config.siteConfig;
    final remoteVersion = site?.appVersion?.trim() ?? '';
    if (remoteVersion.isEmpty) return;
    if (_currentAppVersion.trim().isEmpty) {
      _currentAppVersion = _fallbackLocalAppVersion;
    }
    if (_lastShownUpdateVersion == remoteVersion) return;
    _isCheckingUpdate = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showUpdateDialogIfNeeded(site);
    });
  }

  Future<void> _loadCurrentAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _currentAppVersion = _normalizeLocalAppVersion(info.version);
      });
      _scheduleUpdateModal(context.read<SystemProvider>());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _currentAppVersion = _fallbackLocalAppVersion;
      });
      _scheduleUpdateModal(context.read<SystemProvider>());
    }
  }

  String _normalizeLocalAppVersion(String version) {
    final value = version.trim();
    if (value.isEmpty || value == '0.0.0') return _fallbackLocalAppVersion;
    return value;
  }

  Widget _buildHomeBody() {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshHomeData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 12.h),
              child: Column(
                children: [
                  _buildTopBannerSection(
                    topInset: MediaQuery.of(context).padding.top + 12.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Selector<SystemProvider, List<NoticeModel>>(
                          selector: (_, provider) => provider.config.notices,
                          builder: (context, notices, child) {
                            return NoticeBar(
                              text: _noticeText(notices),
                              leftIcon: const Icon(Icons.volume_up_outlined),
                              backgroundColor: Colors.white,
                              color: AppColors.primary,
                            );
                          },
                        ),
                        _buildUserActionCard(),
                        _buildGameLobby(),
                        _buildRecoGamesSection(),
                        _buildHotGamesSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshHomeData() async {
    final gameProvider = context.read<GameProvider>();
    await Future.wait([
      _loadHomeCategories(refresh: true).catchError((_) {}),
      gameProvider.loadRecommendedGames(refresh: true).catchError((_) {}),
      gameProvider.loadHotGames(refresh: true).catchError((_) {}),
    ]);
  }

  Future<void> _loadHomeCategories({bool refresh = false}) async {
    final categories = await context.read<GameProvider>().fetchCategories(
          refresh: refresh,
        );
    if (!mounted) return;
    setState(() => _homeCategories = categories);
  }

  Widget _buildTopBannerSection({required double topInset}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4EFFF), Color(0xFFF4F6F9)],
        ),
      ),
      padding: EdgeInsets.only(
        top: topInset,
        left: 12.w,
        right: 12.w,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Selector<SystemProvider, SiteConfig?>(
                  selector: (_, provider) => provider.config.siteConfig,
                  builder: (context, siteConfig, child) {
                    return _buildSiteBrand(siteConfig);
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Selector<SystemProvider, SiteConfig?>(
                  selector: (_, provider) => provider.config.siteConfig,
                  builder: (context, siteConfig, child) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () => _copySafeDomain(siteConfig),
                            child: _buildDomainBadge(siteConfig),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: _showLanguageSheet,
                          child: _buildLanguageButton(),
                        ),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => showSearchPanel(context),
                          child: Icon(Icons.search,
                              size: 20.sp, color: const Color(0xFF333333)),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Selector<SystemProvider, List<BannerModel>>(
            selector: (_, provider) => provider.config.banners,
            builder: (context, banners, child) {
              final languageCode =
                  context.watch<LanguageProvider>().currentCode;
              final visibleBanners = _visibleBanners(banners, languageCode);
              if (visibleBanners.isEmpty) return _buildFallbackBanner();
              return _buildBannerCarousel(visibleBanners);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD7E9FF), Color(0xFFF2F8FF)],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.primary.withValues(alpha: 0.5),
        size: 32.sp,
      ),
    );
  }

  List<BannerModel> _visibleBanners(
    List<BannerModel> banners,
    String languageCode,
  ) {
    return banners.where((item) {
      final image = item.img?.trim();
      if (image == null || image.isEmpty) return false;
      final terminal = item.terminal ?? 2;
      if (terminal != 2) return false;
      if (item.languages.isEmpty) return true;
      return item.languages.contains(languageCode);
    }).toList();
  }

  Widget _buildLanguageButton() {
    final languageCode = context.watch<LanguageProvider>().currentCode;
    final languages = context.watch<SystemProvider>().config.languages;
    final active = languages.where(
      (item) => (item.code ?? '').trim().toUpperCase() == languageCode,
    );
    final icon = active.isEmpty ? null : active.first.img?.trim();
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: icon == null || icon.isEmpty
          ? Icon(Icons.language, size: 16.sp, color: AppColors.primary)
          : AppNetworkImage(
              url: icon,
              width: 18.w,
              height: 18.w,
              fit: BoxFit.cover,
              errorWidget:
                  Icon(Icons.language, size: 16.sp, color: AppColors.primary),
            ),
    );
  }

  Future<void> _showLanguageSheet() async {
    final systemProvider = context.read<SystemProvider>();
    final languages = _availableLanguages(systemProvider.config.languages);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.sizeOf(context).height * 0.76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(sheetContext).pop(),
                      child: Text(
                        'common.cancel'.tr(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ),
                    Text(
                      'home.selectLanguage'.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    SizedBox(width: 30.w),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF5F6F8)),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 62.w,
                    color: const Color(0xFFF5F6F8),
                  ),
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    final code = _languageOptionCode(language.code);
                    final supported = AppLanguage.supportedCodes.contains(code);
                    final selected =
                        code == context.read<LanguageProvider>().currentCode;
                    return ListTile(
                      minVerticalPadding: 0,
                      minLeadingWidth: 38.w,
                      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                      visualDensity: VisualDensity.standard,
                      leading: _buildLanguageIcon(language.img),
                      title: Text(
                        language.title ?? code,
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: const Color(0xFF333333),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check,
                              color: AppColors.primary, size: 30.sp)
                          : null,
                      onTap: () async {
                        if (!supported) return;
                        final rootContext = this.context;
                        final gameProvider = rootContext.read<GameProvider>();
                        final currentSystemProvider =
                            rootContext.read<SystemProvider>();
                        final currentLanguageProvider =
                            rootContext.read<LanguageProvider>();
                        Navigator.of(sheetContext).pop();
                        if (selected) return;
                        await currentLanguageProvider.changeLanguage(
                          rootContext,
                          code,
                        );
                        if (!rootContext.mounted) return;
                        _resetLanguageSensitiveProviders(rootContext);
                        await currentSystemProvider.loadConfig(refresh: true);
                        if (!mounted) return;
                        _didTryOpenNotice = false;
                        await Future.wait([
                          _loadHomeCategories(refresh: true),
                          gameProvider.loadRecommendedGames(refresh: true),
                          gameProvider.loadHotGames(refresh: true),
                        ]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetLanguageSensitiveProviders(BuildContext context) {
    context.read<GameProvider>().resetForLanguageChange();
    context.read<GameManagementProvider>().resetForLanguageChange();
    context.read<WalletProvider>().resetForLanguageChange();
    context.read<RecordProvider>().resetForLanguageChange();
    context.read<ActivityProvider>().resetForLanguageChange();
    context.read<FeedbackProvider>().resetForLanguageChange();
    context.read<MessageProvider>().resetForLanguageChange();
    context.read<UserProvider>().resetForLanguageChange();
  }

  List<LanguageConfig> _availableLanguages(List<LanguageConfig> languages) {
    final normalized = languages
        .where((item) => (item.code ?? '').trim().isNotEmpty)
        .map(
          (item) => LanguageConfig(
            title: item.title,
            code: _languageOptionCode(item.code),
            img: item.img,
            requiredStatus: item.requiredStatus,
          ),
        )
        .toList();
    if (normalized.isNotEmpty) return normalized;
    return const [
      LanguageConfig(title: '中文简体', code: 'CN'),
      LanguageConfig(title: '繁體中文', code: 'TW'),
      LanguageConfig(title: 'English', code: 'EN'),
      LanguageConfig(title: '日本語', code: 'JP'),
      LanguageConfig(title: '한국어', code: 'KR'),
      LanguageConfig(title: 'ไทย', code: 'TH'),
      LanguageConfig(title: 'Tiếng Việt', code: 'VN'),
      LanguageConfig(title: 'မြန်မာ', code: 'MY'),
    ];
  }

  String _languageOptionCode(String? raw) {
    final value = raw?.trim().toUpperCase() ?? '';
    if (value.isEmpty) return '';
    if (value == 'CN' || value == 'ZH' || value == 'ZH-CN') return 'CN';
    if (value == 'TW' ||
        value == 'TC' ||
        value == 'ZH-TW' ||
        value == 'ZH-HK') {
      return 'TW';
    }
    if (value == 'MY' || value == 'MM' || value == 'MYANMAR') return 'MY';
    if (value == 'EN' || value == 'EN-US' || value == 'EN-GB') return 'EN';
    if (value == 'JP' || value == 'JA' || value == 'JA-JP') return 'JP';
    if (value == 'KR' || value == 'KO' || value == 'KO-KR') return 'KR';
    if (value == 'TH' || value == 'TH-TH') return 'TH';
    if (value == 'VN' || value == 'VI' || value == 'VI-VN') return 'VN';
    return value;
  }

  Widget _buildLanguageIcon(String? image) {
    final url = image?.trim();
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: 14.r,
        backgroundColor: const Color(0xFFE4EFFF),
        child: Icon(Icons.language, size: 16.sp, color: AppColors.primary),
      );
    }
    return ClipOval(
      child: AppNetworkImage(
        url: url,
        width: 28.w,
        height: 28.w,
        fit: BoxFit.cover,
        errorWidget: CircleAvatar(
          radius: 14.r,
          backgroundColor: const Color(0xFFE4EFFF),
          child: Icon(Icons.language, size: 16.sp, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(List<BannerModel> banners) {
    final count = banners.length;
    return SizedBox(
      height: 140.h,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: count,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  IgnorePointer(
                    child: AppNetworkImage(
                      url: banner.img,
                      width: double.infinity,
                      height: 140.h,
                      borderRadius: BorderRadius.circular(12.r),
                      errorWidget: _buildFallbackBanner(),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () => _handleBannerTap(banner),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (count > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (index) {
                  final selected = index == _bannerIndex % count;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 14.w : 6.w,
                    height: 6.h,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSiteBrand(SiteConfig? siteConfig) {
    return Row(
      children: [
        _buildSiteLogo(siteConfig?.logo, size: 28.w, circular: true),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
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
        ),
      ],
    );
  }

  Widget _buildDomainBadge(SiteConfig? siteConfig) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined,
              size: 14.sp, color: const Color(0xFFF80000)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              _siteText(siteConfig?.domain, fallback: 'flutter.dev'),
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFF80000),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteLogo(
    String? logoUrl, {
    required double size,
    bool circular = false,
  }) {
    final fallback = SizedBox(width: size, height: size);
    if (logoUrl == null || logoUrl.trim().isEmpty) return fallback;

    return AppNetworkImage(
      url: logoUrl,
      width: size,
      height: size,
      borderRadius: circular
          ? BorderRadius.circular(size / 2)
          : BorderRadius.circular(8.r),
      errorWidget: fallback,
    );
  }

  String _siteText(String? value, {required String fallback}) {
    final text = value?.trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _amountText(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final amount = num.tryParse(value.toString());
    if (amount == null) return value.toString();
    return amount.toStringAsFixed(2);
  }

  Future<void> _handleBannerTap(BannerModel banner) async {
    final openUrl = banner.openUrl?.trim();
    if (openUrl == null || openUrl.isEmpty) return;

    final uri = Uri.tryParse(openUrl);
    if (uri == null) return;

    if (uri.scheme == 'http' || uri.scheme == 'https') {
      await _openUrl(openUrl, external: banner.open == 1);
      return;
    }
    context.push(openUrl.startsWith('/') ? openUrl : '/$openUrl');
  }

  Future<void> _openUrl(
    String url, {
    bool external = false,
    ExternalUrlType type = ExternalUrlType.banner,
  }) async {
    final opened = await UrlPolicy.launchExternal(
      url,
      type: type,
      mode: external
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('common.openLinkFailed'.tr())),
      );
    }
  }

  String _noticeText(List<NoticeModel> notices) {
    final text = notices
        .map((notice) => _stripHtml(notice.content ?? notice.title ?? ''))
        .where((content) => content.isNotEmpty)
        .join('   |   ');
    return text.isEmpty ? 'home.fallbackNotice'.tr() : text;
  }

  List<NoticeModel> _popupNotices(List<NoticeModel> notices) {
    final list = notices.where((notice) {
      if (notice.popUp != 1) return false;
      final terminal = notice.terminal ?? 1;
      if (terminal != 1 && terminal != 3) return false;
      final title = notice.title?.trim() ?? '';
      final content = notice.content?.trim() ?? '';
      return title.isNotEmpty || content.isNotEmpty;
    }).toList();
    list.sort((a, b) {
      final topCompare = (b.top ?? 0).compareTo(a.top ?? 0);
      if (topCompare != 0) return topCompare;
      return b.id.compareTo(a.id);
    });
    return list;
  }

  String _localYmd(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  Future<void> _showNoticeModalIfAllowed(List<NoticeModel> notices) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _localYmd(DateTime.now());
    final visibleNotices = _visiblePopupNoticesForToday(prefs, notices, today);
    if (visibleNotices.isEmpty) return;
    if (!mounted) return;
    final result = await showDialog<_NoticeDialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NoticeDialog(notices: visibleNotices),
    );
    if (result?.todayNoMore == true) {
      await _writeSuppressedNoticeIds(
        prefs,
        today,
        visibleNotices.map((notice) => notice.id).toSet(),
      );
    } else {
      await _writeSuppressedNoticeIds(prefs, today, const <int>{});
    }
  }

  Future<void> _showUpdateDialogIfNeeded(SiteConfig? siteConfig) async {
    final remoteVersion = VersionUtils.normalize(siteConfig?.appVersion);
    final localVersion = VersionUtils.normalize(_currentAppVersion);
    if (remoteVersion.isEmpty || localVersion.isEmpty) {
      _isCheckingUpdate = false;
      _didCompleteUpdateCheck = true;
      if (mounted) setState(() {});
      return;
    }
    final hasUpdate = VersionUtils.isRemoteNewer(remoteVersion, localVersion);
    if (!hasUpdate) {
      _isCheckingUpdate = false;
      _didCompleteUpdateCheck = true;
      if (mounted) setState(() {});
      return;
    }

    try {
      final store = await SharedPreferences.getInstance();
      final suppressedVersion =
          store.getString(_updateSuppressVersionKey)?.trim() ?? '';
      if (suppressedVersion == remoteVersion ||
          _lastShownUpdateVersion == remoteVersion) {
        _isCheckingUpdate = false;
        _didCompleteUpdateCheck = true;
        if (mounted) setState(() {});
        return;
      } else {
        if (!mounted) return;
        _isUpdateDialogOpen = true;
        _isCheckingUpdate = false;
        final shouldDownload = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => _UpdateDialog(
            currentVersion: localVersion,
            latestVersion: remoteVersion,
            description: _updateDescriptionText(siteConfig),
            onLater: () => Navigator.of(dialogContext).pop(false),
            onDownload: () => Navigator.of(dialogContext).pop(true),
          ),
        );

        if (shouldDownload == true) {
          await _openAppDownload(siteConfig);
        } else {
          await store.setString(_updateSuppressVersionKey, remoteVersion);
        }
        _lastShownUpdateVersion = remoteVersion;
      }
    } catch (_) {
      _isCheckingUpdate = false;
    } finally {
      _isUpdateDialogOpen = false;
      _didCompleteUpdateCheck = true;
      if (mounted) setState(() {});
    }
  }

  String _updateDescriptionText(SiteConfig? siteConfig) {
    final text =
        siteConfig?.appDesc?.trim() ?? siteConfig?.description?.trim() ?? '';
    if (text.isNotEmpty) return text;
    return 'home.updateTip'.tr();
  }

  Future<void> _openAppDownload(SiteConfig? siteConfig) async {
    final url = _preferredDownloadUrl(siteConfig);
    if (url == null || url.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('home.updateDownloadMissing'.tr())),
      );
      return;
    }
    final uri = UrlPolicy.externalUri(url, type: ExternalUrlType.appDownload) ??
        Uri.tryParse(UrlPolicy.normalize(url));
    final opened = uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('common.openLinkFailed'.tr())),
      );
    }
  }

  String? _preferredDownloadUrl(SiteConfig? siteConfig) {
    if (siteConfig == null) return null;
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      final ios = siteConfig.iosDownload?.trim() ?? '';
      if (ios.isNotEmpty) return ios;
    }
    if (platform == TargetPlatform.android) {
      final apk = siteConfig.apkDownload?.trim() ?? '';
      if (apk.isNotEmpty) return apk;
    }
    final app = siteConfig.appDownload?.trim() ?? '';
    if (app.isNotEmpty) return app;
    final apk = siteConfig.apkDownload?.trim() ?? '';
    if (apk.isNotEmpty) return apk;
    final ios = siteConfig.iosDownload?.trim() ?? '';
    if (ios.isNotEmpty) return ios;
    return null;
  }

  List<NoticeModel> _visiblePopupNoticesForToday(
    SharedPreferences prefs,
    List<NoticeModel> notices,
    String today,
  ) {
    final suppressed = _readSuppressedNoticeIds(prefs, today);
    return notices
        .where((notice) => notice.id <= 0 || !suppressed.contains(notice.id))
        .toList();
  }

  Set<int> _readSuppressedNoticeIds(SharedPreferences prefs, String today) {
    final raw = prefs.getString(_noticeSuppressDateKey)?.trim() ?? '';
    if (raw.isEmpty) return const <int>{};
    if (raw == today) return {-1};
    final parts = raw.split('|');
    if (parts.length != 2 || parts.first != today) return const <int>{};
    return parts.last
        .split(',')
        .map((item) => int.tryParse(item.trim()))
        .whereType<int>()
        .toSet();
  }

  Future<void> _writeSuppressedNoticeIds(
    SharedPreferences prefs,
    String today,
    Set<int> ids,
  ) async {
    final normalized = ids.where((id) => id > 0).toSet();
    if (normalized.isEmpty) {
      await prefs.remove(_noticeSuppressDateKey);
      return;
    }
    final idText = normalized.toList()..sort();
    await prefs.setString(_noticeSuppressDateKey, '$today|${idText.join(',')}');
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '')
        .trim();
  }

  Widget _buildUserActionCard() {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.profile;
    final isLoggedIn = authProvider.isAuthenticated;
    final username = _siteText(
      profile?.nickname ?? profile?.username,
      fallback: 'home.memberUser'.tr(),
    );
    final vipText = profile?.displayVipLevel ?? 'VIP0';
    final symbol = _siteText(profile?.symbol, fallback: '¥');
    final balance = _amountText(profile?.balance, fallback: '0.00');

    return HomeUserActionCard(
      isLoggedIn: isLoggedIn,
      username: username,
      vipText: vipText,
      symbol: symbol,
      balance: balance,
      showBalance: _showBalance,
      welcomeText: 'home.welcome'.tr(),
      loginText: 'common.login'.tr(),
      registerText: 'common.register'.tr(),
      depositText: 'common.deposit'.tr(),
      withdrawText: 'common.withdraw'.tr(),
      serviceText: 'common.service'.tr(),
      onToggleBalance: () => setState(() => _showBalance = !_showBalance),
      onRefresh: _refreshAccount,
      onLogin: () => context.push('/login'),
      onRegister: () => context.push('/register'),
      onDeposit: () => context.push('/deposit'),
      onWithdraw: () => context.push('/withdraw'),
      onService: () => navigateToServiceTab(context),
    );
  }

  Future<void> _copySafeDomain(SiteConfig? siteConfig) async {
    final domain = siteConfig?.domain?.trim();
    if (domain == null || domain.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: domain));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('home.safeDomainCopied'.tr())),
    );
  }

  Future<void> _refreshAccount() async {
    if (!context.read<AuthProvider>().isAuthenticated) return;
    await Future.wait([
      context
          .read<UserProvider>()
          .loadProfile(refresh: true)
          .catchError((_) {}),
      context
          .read<WalletProvider>()
          .loadRealtimeBalance(refresh: true)
          .catchError((_) {}),
    ]);
  }

  Widget _buildGameLobby() {
    final categories = _homeCategories;
    final live = homeCategoryOrNull(categories, 'live');
    final lottery = homeCategoryOrNull(categories, 'lottery');
    final game = homeCategoryOrNull(categories, 'game');
    final sport = homeCategoryOrNull(categories, 'sport');
    final fishing = homeCategoryOrNull(categories, 'fishing');
    final poker = homeCategoryOrNull(categories, 'poker');
    final esports = homeCategoryOrNull(categories, 'esports');
    final largeImageHeight = 148.h;
    final largeTextHeight = 92.h;
    final largeCardHeight = largeImageHeight + largeTextHeight;
    final mediumCardHeight = (largeCardHeight - 10.h) / 2;
    final smallCardHeight = 86.h;
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildLargeCategoryCard(
                  live,
                  height: largeCardHeight,
                  imageHeight: largeImageHeight,
                  image: AppImages.zr,
                  englishTitle: 'Live',
                  fallbackTitle: 'home.category.liveShort'.tr(),
                  description: 'home.category.liveDesc'.tr(),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: largeCardHeight,
                  child: Column(
                    children: [
                      _buildMediumCategoryCard(
                        lottery,
                        height: mediumCardHeight,
                        image: AppImages.cp,
                        englishTitle: 'Lottery',
                        fallbackTitle: 'home.category.lotteryShort'.tr(),
                        description: 'home.category.lotteryDesc'.tr(),
                      ),
                      SizedBox(height: 10.h),
                      _buildMediumCategoryCard(
                        game,
                        height: mediumCardHeight,
                        image: AppImages.dz,
                        englishTitle: 'Slot',
                        fallbackTitle: 'home.category.slotShort'.tr(),
                        description: 'home.category.slotDesc'.tr(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildSmallGameCard(
                sport,
                AppImages.ty,
                smallCardHeight,
                fallbackTitle: 'home.category.sportShort'.tr(),
              ),
              SizedBox(width: 10.w),
              _buildSmallGameCard(
                fishing,
                AppImages.by,
                smallCardHeight,
                fallbackTitle: 'home.category.fishingShort'.tr(),
              ),
              SizedBox(width: 10.w),
              _buildSmallGameCard(
                poker,
                AppImages.qp,
                smallCardHeight,
                fallbackTitle: 'home.category.pokerShort'.tr(),
              ),
              SizedBox(width: 10.w),
              _buildSmallGameCard(
                esports,
                AppImages.dj,
                smallCardHeight,
                fallbackTitle: 'home.category.esportsShort'.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openGameCategory(GameLobbyCategory? category) {
    final code = category?.code.trim() ?? '';
    if (code.isEmpty) return;
    context.go('/game?code=${Uri.encodeQueryComponent(code)}');
  }

  Widget _buildLargeCategoryCard(
    GameLobbyCategory? category, {
    required double height,
    required double imageHeight,
    required String image,
    required String englishTitle,
    required String fallbackTitle,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _openGameCategory(category),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            HomeLargeCategoryArtwork(
              image: image,
              height: imageHeight,
              borderRadius: 16.r,
            ),
            SizedBox(
              height: height - imageHeight,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 4.h,
                    child: Text(
                      englishTitle,
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFC8DCFF).withValues(alpha: 0.4),
                        letterSpacing: 2,
                        height: 1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 5.h, 16.w, 5.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryTitle(
                          _homeCategoryTitle(category, fallbackTitle),
                          fontSize: 16.sp,
                          centered: true,
                        ),
                        SizedBox(height: 1.h),
                        Flexible(
                          child: Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF666666),
                              height: 1.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumCategoryCard(
    GameLobbyCategory? category, {
    required double height,
    required String image,
    required String englishTitle,
    required String fallbackTitle,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _openGameCategory(category),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 12.w,
                    child: Text(
                      englishTitle,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFFC8DCFF).withValues(alpha: 0.4),
                        height: 1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCategoryTitle(
                          _homeCategoryTitle(category, fallbackTitle),
                          fontSize: 17.sp,
                          lineWidth: 4.w,
                          lineHeight: 16.h,
                        ),
                        SizedBox(height: 6.h),
                        Flexible(
                          child: Text(
                            description,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF666666),
                              height: 1.12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 70.w,
              height: double.infinity,
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(image, width: 70.w, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTitle(
    String title, {
    required double fontSize,
    double? lineWidth,
    double? lineHeight,
    bool centered = false,
  }) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      mainAxisSize: centered ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: lineWidth ?? 5.w,
          height: lineHeight ?? 18.h,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF333333),
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  String _shortCategoryTitle(String title) {
    return title;
  }

  String _homeCategoryTitle(GameLobbyCategory? category, String fallbackTitle) {
    final title = category?.title.trim() ?? '';
    if (title.isNotEmpty) return _shortCategoryTitle(title);
    return fallbackTitle;
  }

  Widget _buildSmallGameCard(
    GameLobbyCategory? category,
    String image,
    double height, {
    required String fallbackTitle,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _openGameCategory(category),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Image.asset(
                  image,
                  width: 52.w,
                  height: 52.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 3.h.clamp(1.0, 3.0)),
              SizedBox(
                height: 18.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _homeCategoryTitle(category, fallbackTitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                      height: 1.1,
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

  Widget _buildRecoGamesSection() {
    final gameProvider = context.watch<GameProvider>();
    final remoteGames = gameProvider.recommendedGames;
    final hasRemoteData = remoteGames.isNotEmpty;
    final launchingGameId = gameProvider.launchingGameId;

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildSectionHeader('home.recommendedGames'.tr(),
              onMoreTap: () => context.go('/game')),
          SizedBox(height: 12.h),
          if (gameProvider.isRecommendedLoading && !hasRemoteData)
            SizedBox(
              height: 128.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (hasRemoteData)
            _buildRecoGameList(
              remoteGames,
              launchingGameId: launchingGameId,
            )
          else if ((gameProvider.recommendedError ?? '').trim().isNotEmpty)
            _buildErrorGameSection(
              gameProvider.recommendedError!,
              () => gameProvider.loadRecommendedGames(refresh: true),
            )
          else
            _buildEmptyGameSection('game.noGame'.tr()),
        ],
      ),
    );
  }

  Widget _buildRecoGameList(
    List<RecommendedGame> games, {
    required int? launchingGameId,
  }) {
    final cardSize = _recoGameCardSize;
    return SizedBox(
      height: cardSize + 58,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: games
              .map((game) => _buildRemoteRecoGameCard(
                    game,
                    isLaunching: launchingGameId == game.id,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRemoteRecoGameCard(
    RecommendedGame game, {
    required bool isLaunching,
  }) {
    final cardSize = _recoGameCardSize;

    return GestureDetector(
      onTap: () {
        if (game.isMaintaining || isLaunching) return;
        if (game.opensSubList) {
          _openRecommendedSubList(game);
          return;
        }
        _launchRecommendedGame(game.launchTarget);
      },
      child: Container(
        width: cardSize,
        margin: EdgeInsets.only(right: _recoGameCardGap),
        child: Column(
          children: [
            SizedBox(
              width: cardSize,
              height: cardSize,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: AppNetworkImage(
                      url: game.img ?? '',
                      width: cardSize,
                      height: cardSize,
                      optimize: false,
                      errorWidget: _buildGameImageFallback(
                        width: cardSize,
                        height: cardSize,
                      ),
                    ),
                  ),
                  if (game.isMaintaining)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'common.maintaining'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (isLaunching)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.48),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'common.launching'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 22,
              child: Center(
                child: Text(
                  game.title,
                  style: TextStyle(
                      fontSize: 13.sp, color: const Color(0xFF333333)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRecommendedSubList(RecommendedGame game) {
    final code = game.subListCode.trim();
    final gameCode = game.subListGame.trim();
    if (code.isEmpty || gameCode.isEmpty) return;
    context.push(
      '/game-sub?code=${Uri.encodeQueryComponent(code)}&game=${Uri.encodeQueryComponent(gameCode)}&title=${Uri.encodeQueryComponent(game.title)}',
    );
  }

  Future<void> _launchRecommendedGame(GameLaunchTarget target) async {
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
          SnackBar(content: Text('common.enterGameFailed'.tr())),
        );
        return;
      }
      if (UrlPolicy.gameUri(urlText) == null) {
        messenger.showSnackBar(
          SnackBar(content: Text('common.invalidGameUrl'.tr())),
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
            SnackBar(content: Text('common.openGameFailed'.tr())),
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
          content: Text(
            message?.trim().isNotEmpty == true
                ? message!
                : 'common.enterGameFailed'.tr(),
          ),
        ),
      );
    }
  }

  Widget _buildHotGamesSection() {
    final gameProvider = context.watch<GameProvider>();
    final hotGames = gameProvider.hotGames;
    final hasRemoteData = hotGames.isNotEmpty;
    final launchingGameId = gameProvider.launchingGameId;

    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: Column(
        children: [
          _buildSectionHeader('home.hotGames'.tr(),
              onMoreTap: () => context.go('/game')),
          SizedBox(height: 12.h),
          if (gameProvider.isHotGamesLoading && !hasRemoteData)
            SizedBox(
              height: 180.h,
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (hasRemoteData)
            _buildHotGameGrid(
              hotGames,
              launchingGameId: launchingGameId,
            )
          else if ((gameProvider.hotGamesError ?? '').trim().isNotEmpty)
            _buildErrorGameSection(
              gameProvider.hotGamesError!,
              () => gameProvider.loadHotGames(refresh: true),
            )
          else
            _buildEmptyGameSection('game.noGame'.tr()),
        ],
      ),
    );
  }

  Widget _buildHotGameGrid(
    List<GameItem> games, {
    required int? launchingGameId,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildRemoteHotGameCard(
          game,
          isLaunching: launchingGameId == game.id,
        );
      },
    );
  }

  Widget _buildRemoteHotGameCard(
    GameItem game, {
    required bool isLaunching,
  }) {
    return GestureDetector(
      onTap: () {
        if (game.isMaintaining || isLaunching) return;
        _launchRecommendedGame(game.launchTarget);
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: AppNetworkImage(
                    url: game.img ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    optimize: false,
                    errorWidget: _buildHotFallbackImage(),
                  ),
                ),
                if (game.isMaintaining)
                  _buildGameMask('common.maintaining'.tr()),
                if (isLaunching) _buildLaunchingMask(),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            game.title ?? '',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF333333)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyGameSection(String message) {
    return SizedBox(
      height: 96.h,
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _buildErrorGameSection(String message, VoidCallback onRetry) {
    return RetryEmptyState(
      message: message,
      onRetry: onRetry,
      height: 136.h,
      compact: true,
    );
  }

  Widget _buildHotFallbackImage() {
    return _buildGameImageFallback(
      width: double.infinity,
      height: double.infinity,
      borderRadius: BorderRadius.circular(16.r),
    );
  }

  Widget _buildGameImageFallback({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    final child = Container(
      width: width,
      height: height,
      color: const Color(0xFFEFF3F8),
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 28.sp,
        color: AppColors.textSecondary,
      ),
    );
    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius, child: child);
  }

  Widget _buildGameMask(String text) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchingMask() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'common.launching'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMoreTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onMoreTap,
          child: Text(
            'common.more'.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpdateDialog extends StatelessWidget {
  const _UpdateDialog({
    required this.currentVersion,
    required this.latestVersion,
    required this.description,
    required this.onLater,
    required this.onDownload,
  });

  final String currentVersion;
  final String latestVersion;
  final String description;
  final VoidCallback onLater;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 22.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.78), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8F1FF), Color(0xFFFFFFFF)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withValues(alpha: 0.24),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(Icons.system_update_alt_rounded,
                            color: Colors.white, size: 24.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'home.updateTitle'.tr(),
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'home.updateLatestVersion'
                                  .tr(namedArgs: {'version': latestVersion}),
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFF8FAFC).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'home.updateCurrentVersion'
                                    .tr(namedArgs: {'version': currentVersion}),
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: const Color(0xFF475569)),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 18.h,
                              color: const Color(0xFFE2E8F0),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'v$latestVersion',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.55,
                            color: const Color(0xFF334155)),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onLater,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side:
                                    const BorderSide(color: Color(0xFFCBD5E1)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r)),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text('home.updateLater'.tr()),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onDownload,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r)),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text('home.downloadNow'.tr()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeDialog extends StatefulWidget {
  const _NoticeDialog({required this.notices});

  final List<NoticeModel> notices;

  @override
  State<_NoticeDialog> createState() => _NoticeDialogState();
}

class _NoticeDialogResult {
  const _NoticeDialogResult({required this.todayNoMore});

  final bool todayNoMore;
}

class _NoticeDialogState extends State<_NoticeDialog> {
  int _index = 0;
  bool _todayNoMore = false;

  NoticeModel get _current => widget.notices[_index];

  bool get _hasNext => _index < widget.notices.length - 1;

  void _close() {
    if (_todayNoMore || !_hasNext) {
      Navigator.of(context).pop(_NoticeDialogResult(todayNoMore: _todayNoMore));
      return;
    }
    setState(() => _index += 1);
  }

  Future<void> _handleNoticeTap() async {
    final openUrl = _current.openUrl?.trim();
    if (openUrl == null || openUrl.isEmpty) return;
    Navigator.of(context).pop(_NoticeDialogResult(todayNoMore: _todayNoMore));
    if (openUrl.startsWith('/')) {
      context.push(openUrl);
      return;
    }
    final uri = UrlPolicy.externalUri(openUrl, type: ExternalUrlType.banner);
    if (uri != null) {
      await UrlPolicy.launchExternal(
        openUrl,
        type: ExternalUrlType.banner,
        mode: _current.open == 1
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );
      return;
    }
    if (context.mounted) context.push('/$openUrl');
  }

  @override
  Widget build(BuildContext context) {
    final title = (_current.title?.trim().isNotEmpty ?? false)
        ? _current.title!.trim()
        : 'home.notice.titleFallback'.tr();
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.78), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.16),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF93C5FD)],
                            ),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          child: Icon(Icons.campaign_rounded,
                              size: 20.sp, color: Colors.white),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (widget.notices.length > 1) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_index + 1}/${widget.notices.length}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: _close,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 330.h),
                        child: SingleChildScrollView(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _handleNoticeTap,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _NoticeContent(content: _current.content),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    InkWell(
                      onTap: () => setState(() => _todayNoMore = !_todayNoMore),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: Checkbox(
                                value: _todayNoMore,
                                onChanged: (value) => setState(
                                    () => _todayNoMore = value ?? false),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                side:
                                    const BorderSide(color: Color(0xFFCBD5E1)),
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.r)),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'home.notice.todayNoMore'.tr(),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeContent extends StatelessWidget {
  const _NoticeContent({required this.content});

  final String? content;

  @override
  Widget build(BuildContext context) {
    final raw = content?.trim() ?? '';
    if (raw.isEmpty) return _plainText('');
    final sanitized = _sanitizeHtml(raw);
    if (!_looksLikeHtml(sanitized)) return _plainText(_decodeHtml(sanitized));
    final blocks = _parseHtmlBlocks(sanitized);
    if (blocks.isEmpty) return _plainText(_htmlToPlainText(sanitized));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) _NoticeHtmlBlock(block: block),
      ],
    );
  }

  Widget _plainText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        color: const Color(0xFF333333),
        height: 1.55,
      ),
    );
  }

  bool _looksLikeHtml(String value) {
    return RegExp(r'</?[a-z][\s\S]*>', caseSensitive: false).hasMatch(value);
  }

  String _sanitizeHtml(String value) {
    return value
        .replaceAll(
            RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), '')
        .replaceAll(RegExp(r'\son\w+\s*=\s*"[^"]*"', caseSensitive: false), '')
        .replaceAll(RegExp(r"\son\w+\s*=\s*'[^']*'", caseSensitive: false), '')
        .replaceAll(
            RegExp(r'\s(href|src)\s*=\s*"\s*javascript:[^"]*"',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(r"\s(href|src)\s*=\s*'\s*javascript:[^']*'",
                caseSensitive: false),
            '');
  }

  List<_NoticeHtmlBlockData> _parseHtmlBlocks(String html) {
    final normalized = html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
            RegExp(r'</(p|div|section|article|h[1-6])>', caseSensitive: false),
            '\n')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</tr>', caseSensitive: false), '\n');
    final blocks = <_NoticeHtmlBlockData>[];
    var cursor = 0;
    final imageRegex = RegExp(
      r'''<img\b[^>]*\bsrc\s*=\s*(["'])(.*?)\1[^>]*>''',
      caseSensitive: false,
    );

    for (final match in imageRegex.allMatches(normalized)) {
      final before = normalized.substring(cursor, match.start);
      _appendTextBlocks(blocks, before);
      final src = _decodeHtml(match.group(2) ?? '').trim();
      if (src.isNotEmpty) blocks.add(_NoticeHtmlImageBlock(src));
      cursor = match.end;
    }

    _appendTextBlocks(blocks, normalized.substring(cursor));
    return blocks;
  }

  void _appendTextBlocks(List<_NoticeHtmlBlockData> blocks, String html) {
    final text = _htmlToPlainText(html);
    for (final line in text.split(RegExp(r'\n{2,}'))) {
      final normalized = line.trim();
      if (normalized.isNotEmpty) blocks.add(_NoticeHtmlTextBlock(normalized));
    }
  }

  String _htmlToPlainText(String html) {
    return _decodeHtml(html
            .replaceAll(RegExp(r'<li\b[^>]*>', caseSensitive: false), '\n• ')
            .replaceAll(RegExp(r'</t[dh]>', caseSensitive: false), '  ')
            .replaceAll(RegExp(r'<[^>]+>'), ''))
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _decodeHtml(String value) {
    return value
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }
}

abstract class _NoticeHtmlBlockData {
  const _NoticeHtmlBlockData();
}

class _NoticeHtmlTextBlock extends _NoticeHtmlBlockData {
  const _NoticeHtmlTextBlock(this.text);

  final String text;
}

class _NoticeHtmlImageBlock extends _NoticeHtmlBlockData {
  const _NoticeHtmlImageBlock(this.url);

  final String url;
}

class _NoticeHtmlBlock extends StatelessWidget {
  const _NoticeHtmlBlock({required this.block});

  final _NoticeHtmlBlockData block;

  @override
  Widget build(BuildContext context) {
    final data = block;
    if (data is _NoticeHtmlImageBlock) {
      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: AppNetworkImage(
          url: data.url,
          width: double.infinity,
          height: 180.h,
          fit: BoxFit.contain,
          borderRadius: BorderRadius.circular(10.r),
          optimize: false,
        ),
      );
    }
    final text = data is _NoticeHtmlTextBlock ? data.text : '';
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFF333333),
          height: 1.55,
        ),
      ),
    );
  }
}
