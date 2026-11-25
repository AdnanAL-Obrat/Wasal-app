import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_content.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/brand_card.dart';
import '../../../../core/widgets/media.dart';
import '../../../../core/widgets/route_progress.dart';
import '../../../../core/widgets/spread_row.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/timeline_stage_model.dart';
import '../../../order_detail/controllers/delivery_progress.dart';
import 'status_chip.dart';

/// كرت الطلب: المطعم، الحالة، الوقت، المبلغ، الأطباق.
class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = StatusStyle.of(context, order);
    final total = AppFormatters.money(order.total, currency: order.currency);
    return BrandCard(
      onTap: onTap,
      padding: const EdgeInsetsDirectional.all(BrandSpacing.md),
      semanticLabel: 'order_card_semantics'.trParams({
        'id': order.id,
        'status': style.label,
        'total': total,
      }),
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoreLogo(
              path: order.storeLogo,
              size: 52,
              badge: StatusBadge(order: order),
            ),
            const SizedBox(width: BrandSpacing.sm),
            Expanded(
              child: _Body(order: order, style: style, total: total),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.order, required this.style, required this.total});

  final OrderModel order;
  final StatusStyle style;
  final String total;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final cancelled = order.status == OrderStatus.cancelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpreadRow(
          leading: Text(
            order.storeName ?? AppContent.orderNumber(order.id),
            style: text.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            total,
            style: text.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
              // الطلب الملغي: المبلغ مشطوب.
              decoration: cancelled ? TextDecoration.lineThrough : null,
              color: cancelled ? palette.textSecondary : null,
            ),
          ),
        ),
        const SizedBox(height: BrandSpacing.xxs),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: style.label,
                style: TextStyle(
                  color: style.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: '  ·  ${AppFormatters.friendlyDate(order.date)}'),
            ],
          ),
          style: text.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (!order.status.isFinal) ...[
          const SizedBox(height: BrandSpacing.sm),
          RouteProgress(
            stages: DeliveryStage.flow.length,
            reached: DeliveryProgress.reachedIndex(order),
            color: style.base,
            trackColor: palette.border,
            holeColor: palette.surface,
            height: 14,
          ),
        ],
        const SizedBox(height: BrandSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OrderIdText(id: order.id, style: text.labelSmall),
            ),
            FoodStack(images: [for (final i in order.items) i.image]),
          ],
        ),
      ],
    );
  }
}

/// رقم الطلب باتجاه LTR ليبقى «#» في البداية.
class OrderIdText extends StatelessWidget {
  const OrderIdText({super.key, required this.id, this.style});

  final String id;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Text(
      AppContent.orderNumber(id),
      style: style?.copyWith(letterSpacing: 0.4),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
