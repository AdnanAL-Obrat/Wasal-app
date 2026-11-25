import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/route_pattern.dart';

/// هيدر الشاشة الرئيسية مع كرت الطلب الجاري.
class OrdersHero extends StatelessWidget {
  const OrdersHero({
    super.key,
    required this.summary,
    required this.pill,
    this.spotlight,
    this.topInset = 0,
  });

  final String summary;
  final Widget pill;
  final Widget? spotlight;

  /// مساحة شريط الحالة والشريط العلوي.
  final double topInset;

  /// مقدار نزول الكرت تحت الهيدر.
  static const _overhang = 84.0;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final ink = palette.onGradient;
    final hasSpotlight = spotlight != null;
    final side = Responsive.sidePadding(context);
    return Stack(
      children: [
        Positioned.fill(
          bottom: hasSpotlight ? _overhang : 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: palette.headerGradient,
              borderRadius: const BorderRadiusDirectional.vertical(
                bottom: Radius.circular(BrandRadius.hero),
              ).resolve(Directionality.of(context)),
            ),
            child: RoutePattern(color: ink.withValues(alpha: 0.07)),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            side,
            topInset + BrandSpacing.xs,
            side,
            hasSpotlight ? 0 : BrandSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'orders_title'.tr,
                style: TextStyle(
                  fontSize: BrandTypography.heroTitle,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: ink,
                ),
              ),
              const SizedBox(height: BrandSpacing.xxs),
              Text(
                summary,
                style: TextStyle(
                  fontSize: BrandTypography.bodyL,
                  height: BrandTypography.lineHeightBody,
                  color: ink.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: BrandSpacing.md),
              pill,
              if (hasSpotlight) ...[
                const SizedBox(height: BrandSpacing.xl),
                spotlight!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// عنوان القسم مع العدد.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final side = Responsive.sidePadding(context);
    return Padding(
      // 32 فوق، 12 تحت.
      padding: EdgeInsetsDirectional.fromSTEB(
        side,
        BrandSpacing.xxl,
        side,
        BrandSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: palette.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: BrandSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(width: BrandSpacing.xs),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: BrandSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: palette.border,
              borderRadius: BorderRadius.circular(BrandRadius.pill),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
