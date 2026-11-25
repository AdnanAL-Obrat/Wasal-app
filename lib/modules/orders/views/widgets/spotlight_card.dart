import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_content.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/widgets/brand_card.dart';
import '../../../../core/widgets/media.dart';
import '../../../../core/widgets/route_progress.dart';
import '../../../../core/widgets/spread_row.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/timeline_stage_model.dart';
import '../../../order_detail/controllers/delivery_progress.dart';
import 'status_chip.dart';

/// كرت الطلب الجاري: الوقت المتوقع والمسار والمندوب.
class SpotlightCard extends StatelessWidget {
  const SpotlightCard({
    super.key,
    required this.order,
    required this.now,
    required this.onTap,
    required this.onCallCourier,
  });

  final OrderModel order;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onCallCourier;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final style = StatusStyle.of(context, order);
    return BrandCard(
      onTap: onTap,
      raised: true,
      radius: BrandRadius.xl,
      padding: const EdgeInsetsDirectional.all(BrandSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpreadRow(
            gap: BrandSpacing.xs,
            trailingMaxFraction: 0.4,
            leading: Row(
              children: [
                StoreLogo(path: order.storeLogo, size: 52),
                const SizedBox(width: BrandSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'live_order'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.labelSmall?.copyWith(
                          color: palette.primaryDeep,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        order.storeName ?? AppContent.orderNumber(order.id),
                        style: text.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // بدون اسم مطعم يكون الرقم هو العنوان.
                      if (order.storeName != null) ...[
                        const SizedBox(height: BrandSpacing.xxs),
                        _OrderNumberTag(id: order.id),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            trailing: StatusChip(order: order),
          ),
          const SizedBox(height: BrandSpacing.lg),
          // الوقت المتوقع والأطباق.
          SpreadRow(
            trailingMaxFraction: 0.5,
            leading: _EtaBlock(
              window: DeliveryProgress.etaWindow(order.estimatedDelivery, now),
            ),
            trailing: FoodStack(
              images: [for (final i in order.items) i.image],
              size: 44,
            ),
          ),
          const SizedBox(height: BrandSpacing.md),
          RouteProgress(
            stages: DeliveryStage.flow.length,
            reached: DeliveryProgress.reachedIndex(order),
            color: style.base,
            trackColor: palette.border,
            holeColor: palette.surface,
            height: 24,
          ),
          const SizedBox(height: BrandSpacing.xxs),
          Row(
            children: [
              Text('route_from'.tr, style: text.labelSmall),
              const Spacer(),
              Text('route_to'.tr, style: text.labelSmall),
            ],
          ),
          const SizedBox(height: BrandSpacing.md),
          Divider(height: 1, color: palette.border),
          const SizedBox(height: BrandSpacing.md),
          _CourierRow(order: order, onCall: onCallCourier),
        ],
      ),
    );
  }
}

/// شارة رقم الطلب.
class _OrderNumberTag extends StatelessWidget {
  const _OrderNumberTag({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    // يُختصر إذا طال الرقم.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: BrandSpacing.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: palette.primarySoft,
          borderRadius: BorderRadius.circular(BrandRadius.sm),
        ),
        child: Text(
          AppContent.orderNumber(id),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.ltr,
          semanticsLabel: '${'order_number'.tr} $id',
          style: TextStyle(
            fontSize: BrandTypography.caption,
            fontWeight: FontWeight.w700,
            color: palette.primaryDeep,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _EtaBlock extends StatelessWidget {
  const _EtaBlock({required this.window});

  final EtaWindow? window;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final (big, small) = switch (window) {
      EtaWindow(kind: EtaKind.range, :final from, :final to) => (
        '$from–$to',
        'minutes'.tr,
      ),
      EtaWindow(kind: EtaKind.soon) => ('eta_soon_short'.tr, ''),
      EtaWindow(kind: EtaKind.late) => ('eta_late_short'.tr, ''),
      null => ('—', ''),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('eta_label'.tr, style: text.bodySmall),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // يصغر بدل أن يفيض.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  big,
                  style: TextStyle(
                    fontSize: BrandTypography.display,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: palette.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(width: BrandSpacing.xs),
            Text(
              small,
              style: text.titleSmall?.copyWith(color: palette.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _CourierRow extends StatelessWidget {
  const _CourierRow({required this.order, required this.onCall});

  final OrderModel order;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final name = order.courierName;
    if (name == null) {
      return Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: BrandIconography.md,
            color: palette.textSecondary,
          ),
          const SizedBox(width: BrandSpacing.xs),
          Expanded(child: Text('awaiting_courier'.tr, style: text.bodySmall)),
        ],
      );
    }
    return Row(
      children: [
        CourierAvatar(name: name),
        const SizedBox(width: BrandSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('courier_is'.tr, style: text.bodySmall),
              Text(name, style: text.labelMedium, maxLines: 1),
            ],
          ),
        ),
        if (order.hasCourierContact)
          IconButton.filled(
            tooltip: 'call_courier'.tr,
            onPressed: onCall,
            style: IconButton.styleFrom(
              backgroundColor: palette.primary,
              foregroundColor: BrandColors.onPrimary,
              minimumSize: const Size.square(BrandSpacing.minTapTarget),
            ),
            icon: const Icon(Icons.call_rounded),
          ),
      ],
    );
  }
}

/// أول حرف من اسم المندوب.
class CourierAvatar extends StatelessWidget {
  const CourierAvatar({super.key, required this.name, this.radius = 20});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: palette.primarySoft,
      child: Text(
        name.characters.first,
        style: TextStyle(
          color: palette.primaryDeep,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
