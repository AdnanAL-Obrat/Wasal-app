import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/brand_tokens.dart';
import '../../../core/widgets/brand_card.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_view.dart';
import '../../../data/models/order_model.dart';
import '../../orders/views/widgets/spotlight_card.dart';
import '../controllers/order_detail_controller.dart';
import 'widgets/contact_bar.dart';
import 'widgets/delivery_timeline.dart';
import 'widgets/detail_hero.dart';
import 'widgets/order_receipt.dart';

class OrderDetailScreen extends GetView<OrderDetailController> {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isResolving.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final order = controller.order.value;
        return order == null ? const _NotFound() : _Content(order: order);
      }),
      bottomNavigationBar: Obx(() {
        final order = controller.order.value;
        if (order == null) return const SizedBox.shrink();
        return ContactBar(
          showCourier: order.hasCourierContact && !order.status.isFinal,
          // الدعم متاح دائمًا.
          showSupport: true,
          onCallCourier: controller.callCourier,
          onCallSupport: controller.callSupport,
        );
      }),
    );
  }
}

class _Content extends GetView<OrderDetailController> {
  const _Content({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final scheme = HeroScheme.of(context, order.status);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: Responsive.heroHeight(context),
          backgroundColor: scheme.background,
          foregroundColor: scheme.foreground,
          surfaceTintColor: Colors.transparent,
          systemOverlayStyle: scheme.isLight
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          // سهم الرجوع ينعكس تلقائيًا.
          leading: const BackButton(),
          title: Text('order_detail_title'.tr),
          titleTextStyle: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: scheme.foreground),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(BrandRadius.hero),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: Obx(
              () => DetailHero(
                order: order,
                now: controller.now.value,
                onCopyId: controller.copyOrderId,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsetsDirectional.fromSTEB(
            Responsive.sidePadding(context),
            BrandSpacing.xl,
            Responsive.sidePadding(context),
            BrandSpacing.xl,
          ),
          sliver: SliverList.list(children: _sections()),
        ),
      ],
    );
  }

  List<Widget> _sections() {
    const gap = SizedBox(height: BrandSpacing.md);
    final sections = <Widget>[
      SectionCard(
        title: 'delivery_stages'.tr,
        icon: Icons.route_outlined,
        child: Obx(() => DeliveryTimeline(steps: controller.steps)),
      ),
      if (order.courierName != null && !order.status.isFinal)
        _CourierSection(name: order.courierName!),
      OrderReceipt(order: order),
      _AddressSection(order: order, onCopy: controller.copyAddress),
    ];
    return [
      Obx(() => _StaleNote(note: controller.staleNote)),
      for (var i = 0; i < sections.length; i++) ...[
        if (i > 0) gap,
        StaggeredEntrance(index: i, child: sections[i]),
      ],
    ];
  }
}

class _StaleNote extends StatelessWidget {
  const _StaleNote({required this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return AnimatedSize(
      duration: BrandMotion.base,
      curve: BrandMotion.curve,
      child: note == null
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsetsDirectional.only(
                bottom: BrandSpacing.cardGap,
              ),
              padding: const EdgeInsetsDirectional.all(BrandSpacing.sm),
              decoration: BoxDecoration(
                color: p.offlineBannerBg,
                borderRadius: BorderRadius.circular(BrandRadius.lg),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: BrandIconography.md,
                    color: p.offlineBannerFg,
                  ),
                  const SizedBox(width: BrandSpacing.xs),
                  Expanded(
                    child: Text(
                      note!,
                      style: TextStyle(
                        fontSize: BrandTypography.caption,
                        color: p.offlineBannerFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.order, required this.onCopy});

  final OrderModel order;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SectionCard(
      title: 'delivery_address'.tr,
      icon: Icons.location_on_outlined,
      trailing: TextButton.icon(
        onPressed: onCopy,
        icon: const Icon(Icons.copy_rounded, size: BrandIconography.sm),
        label: Text('copy_address'.tr),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: BrandSpacing.xs,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نقطة «هنا».
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: palette.primary,
                shape: BoxShape.circle,
                border: Border.all(color: palette.primarySoft, width: 3),
              ),
            ),
          ),
          const SizedBox(width: BrandSpacing.sm),
          Expanded(
            child: Text(
              order.deliveryAddress,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourierSection extends StatelessWidget {
  const _CourierSection({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return BrandCard(
      child: Row(
        children: [
          CourierAvatar(name: name, radius: 24),
          const SizedBox(width: BrandSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('courier_is'.tr, style: text.bodySmall),
                Text(name, style: text.titleSmall),
              ],
            ),
          ),
          Icon(
            Icons.delivery_dining_outlined,
            color: AppPalette.of(context).primary,
          ),
        ],
      ),
    );
  }
}

class _NotFound extends GetView<OrderDetailController> {
  const _NotFound();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: StateView(
      illustration: BrandAssets.illustrationEmpty,
      title: 'order_not_found_title'.tr,
      message: 'order_not_found_subtitle'.tr,
      actionLabel: 'back_to_orders'.tr,
      actionIcon: Icons.list_alt_rounded,
      onAction: controller.back,
    ),
  );
}
