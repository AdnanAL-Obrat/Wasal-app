import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/brand_card.dart';
import '../../../../core/widgets/media.dart';
import '../../../../core/widgets/spread_row.dart';
import '../../../../core/widgets/ticket.dart';
import '../../../../data/models/order_item_model.dart';
import '../../../../data/models/order_model.dart';

/// الفاتورة: الأصناف والرسوم والإجمالي.
class OrderReceipt extends StatelessWidget {
  const OrderReceipt({super.key, required this.order});

  final OrderModel order;

  String _money(double v) => AppFormatters.money(v, currency: order.currency);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Ticket(
      sections: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(
              title: 'receipt'.tr,
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: BrandSpacing.md),
            Row(
              children: [
                StoreLogo(path: order.storeLogo, size: 48),
                const SizedBox(width: BrandSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (order.storeName != null)
                        Text(order.storeName!, style: text.titleSmall),
                      Text(
                        AppFormatters.fullDateTime(order.date),
                        style: text.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: order.items.isEmpty
              ? [Text('no_items_saved'.tr, style: text.bodySmall)]
              : [for (final i in order.items) _ItemRow(item: i, money: _money)],
        ),
        Column(
          children: [
            _AmountRow(
              label: 'subtotal'.tr,
              value: _money(order.itemsSubtotal),
            ),
            _AmountRow(
              label: 'delivery_fee'.tr,
              value: _money(order.effectiveDeliveryFee),
            ),
          ],
        ),
        _GrandTotal(
          value: _money(order.total),
          voided: order.status == OrderStatus.cancelled,
        ),
      ],
    );
  }
}

/// سطر الصنف: الصورة والكمية والسعر.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.money});

  final OrderItemModel item;
  final String Function(double) money;

  static const _thumb = 56.0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tabular = const [FontFeature.tabularFigures()];
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: BrandSpacing.xs),
      child: SpreadRow(
        leading: Row(
          children: [
            _Thumb(item: item, size: _thumb),
            const SizedBox(width: BrandSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity} × ${money(item.unitPrice)}',
                    style: text.bodySmall?.copyWith(fontFeatures: tabular),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          money(item.subtotal),
          style: text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFeatures: tabular,
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.item, required this.size});

  final OrderItemModel item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SizedBox.square(
      dimension: size + 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          BrandImage(
            path: item.image,
            size: size,
            radius: BrandRadius.md,
            fallbackIcon: Icons.lunch_dining_rounded,
          ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 6,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: palette.secondary,
                borderRadius: BorderRadius.circular(BrandRadius.pill),
                border: Border.all(color: palette.surface, width: 2),
              ),
              child: Text(
                '×${item.quantity}',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  fontSize: BrandTypography.caption - 1,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppPalette.of(context).textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _GrandTotal extends StatelessWidget {
  const _GrandTotal({required this.value, required this.voided});

  final String value;

  /// الملغي: الإجمالي مشطوب.
  final bool voided;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return SpreadRow(
      trailingMaxFraction: 0.55,
      leading: Text('grand_total'.tr, style: text.titleSmall),
      trailing: Text(
        value,
        style: text.headlineSmall?.copyWith(
          color: voided ? palette.textSecondary : palette.primaryDeep,
          decoration: voided ? TextDecoration.lineThrough : null,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
