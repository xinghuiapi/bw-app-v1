import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:my_flutter_app/theme/app_theme.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? child;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.skeletonBase,
      highlightColor: AppTheme.skeletonHighlight,
      child: child ?? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black, // 需要有一个颜色才能生效
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class BannerSkeleton extends StatelessWidget {
  const BannerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Skeleton(
        height: 180,
        borderRadius: 15,
      ),
    );
  }
}

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Column(
          children: [
            const Expanded(
              child: Skeleton(borderRadius: 12),
            ),
            const SizedBox(height: 4),
            const Skeleton(width: 40, height: 12, borderRadius: 2),
          ],
        );
      },
    );
  }
}

class GameCardSkeleton extends StatelessWidget {
  const GameCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          child: Skeleton(borderRadius: 12),
        ),
        const SizedBox(height: 8),
        const Skeleton(width: 60, height: 14, borderRadius: 2),
      ],
    );
  }
}
