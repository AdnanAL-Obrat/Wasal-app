import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../data/models/order_model.dart';

/// لون وأيقونة ونص لكل حالة.
class StatusStyle {
  const StatusStyle({
    required this.base,
    required this.foreground,
    required this.background,
    required this.icon,
    required this.label,
  });

  final Color base;
  final Color foreground;
  final Color background;
  final IconData icon;
  final String label;

  factory StatusStyle.of(BuildContext context, OrderModel order) {
    final p = AppPalette.of(context);
    return switch (order.status) {
      OrderStatus.preparing => StatusStyle(
        base: p.statusPreparing,
        foreground: p.statusPreparingFg,
        background: p.statusPreparingBg,
        icon: Icons.soup_kitchen_outlined,
        label: 'status_preparing'.tr,
      ),
      OrderStatus.inTransit => StatusStyle(
        base: p.statusInTransit,
        foreground: p.statusInTransitFg,
        background: p.statusInTransitBg,
        icon: Icons.delivery_dining_outlined,
        label: 'status_in_transit'.tr,
      ),
      OrderStatus.delivered => StatusStyle(
        base: p.statusDelivered,
        foreground: p.statusDeliveredFg,
        background: p.statusDeliveredBg,
        icon: Icons.check_circle_outline_rounded,
        label: 'status_delivered'.tr,
      ),
      OrderStatus.cancelled => StatusStyle(
        base: p.statusCancelled,
        foreground: p.statusCancelledFg,
        background: p.statusCancelledBg,
        icon: Icons.highlight_off_rounded,
        label: 'status_cancelled'.tr,
      ),
      OrderStatus.unknown => StatusStyle(
        base: p.offlineGrey,
        foreground: p.textSecondary,
        background: p.border,
        icon: Icons.help_outline_rounded,
        label: order.statusLabelAr,
      ),
    };
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.order, this.large = false});

  final OrderModel order;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(context, order);
    final fontSize = large ? BrandTypography.bodyM : BrandTypography.caption;
    return AnimatedContainer(
      duration: BrandMotion.base,
      curve: BrandMotion.curve,
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: large ? BrandSpacing.sm : BrandSpacing.xs,
        vertical: BrandSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(BrandRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: fontSize + 4, color: style.base),
          const SizedBox(width: BrandSpacing.xxs),
          Text(
            style.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: style.foreground,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// مربع أيقونة الحالة.
class StatusGlyph extends StatelessWidget {
  const StatusGlyph({super.key, required this.order, this.size = 46});

  final OrderModel order;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(context, order);
    return AnimatedContainer(
      duration: BrandMotion.base,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(BrandRadius.md + 2),
      ),
      child: Icon(style.icon, color: style.base, size: size * 0.5),
    );
  }
}

/// علامة الحالة على زاوية الشعار.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.order, this.size = 22});

  final OrderModel order;
  final double size;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(context, order);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.background,
        shape: BoxShape.circle,
        border: Border.all(color: AppPalette.of(context).surface, width: 2),
      ),
      child: Icon(style.icon, size: size * 0.6, color: style.base),
    );
  }
}
