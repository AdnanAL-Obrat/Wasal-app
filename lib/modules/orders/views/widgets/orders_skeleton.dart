import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';

/// هيكل تحميل بشكل كرت الطلب.
class OrdersSkeleton extends StatelessWidget {
  const OrdersSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Semantics(
      label: 'loading_orders'.tr,
      liveRegion: true,
      child: Shimmer.fromColors(
        baseColor: p.skeletonBase,
        highlightColor: p.skeletonHighlight,
        child: Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(height: BrandSpacing.cardGap),
              _SkeletonCard(withRoute: i == 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.withRoute});

  final bool withRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(BrandSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BrandRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Bone(width: 46, height: 46, radius: BrandRadius.md + 2),
          const SizedBox(width: BrandSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    _Bone(width: 120, height: 14),
                    Spacer(),
                    _Bone(width: 64, height: 14),
                  ],
                ),
                const SizedBox(height: BrandSpacing.xs),
                const _Bone(width: 150, height: 10),
                if (withRoute) ...[
                  const SizedBox(height: BrandSpacing.sm),
                  const _Bone(width: double.infinity, height: 6),
                ],
                const SizedBox(height: BrandSpacing.xs),
                const _Bone(width: 90, height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.width,
    required this.height,
    this.radius = BrandRadius.sm / 2,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
