import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_app/models/home_data.dart';
import 'package:my_flutter_app/theme/app_theme.dart';
import 'package:my_flutter_app/widgets/common/skeleton_widget.dart';
import 'package:my_flutter_app/widgets/common/web_safe_image.dart';

class HomeBanner extends StatelessWidget {
  final List<BannerModel> banners;

  const HomeBanner({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 180,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final banner = banners[index];
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleBannerClick(context, banner),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: banner.img != null
                  ? WebSafeImage(
                      imageUrl: banner.img!,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(15),
                      placeholder: const Skeleton(borderRadius: 15),
                      errorWidget: _buildErrorPlaceholder(banner.title),
                    )
                  : _buildErrorPlaceholder(banner.title),
            ),
          );
        },
        itemCount: banners.length,
        pagination: const SwiperPagination(
          builder: DotSwiperPaginationBuilder(
            activeColor: AppTheme.primary,
            color: Colors.white24,
            size: 6,
            activeSize: 8,
          ),
        ),
        autoplay: banners.length > 1,
      ),
    );
  }

  Widget _buildErrorPlaceholder(String? title) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surface),
      child: Center(
        child: Text(
          title ?? "广告位",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textTertiary,
          ),
        ),
      ),
    );
  }

  void _handleBannerClick(BuildContext context, BannerModel banner) async {
    if (banner.open == 1 &&
        banner.openUrl != null &&
        banner.openUrl!.isNotEmpty) {
      final Uri url = Uri.parse(banner.openUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch ${banner.openUrl}');
      }
    }
  }
}
