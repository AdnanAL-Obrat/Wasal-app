import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/constants/brand_tokens.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/maker_mark.dart';
import '../../../core/widgets/motion.dart';
import '../../../core/widgets/state_view.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../core/widgets/wasal_logo.dart';
import '../../../data/models/order_model.dart';
import '../controllers/orders_controller.dart';
import 'widgets/offline_banner.dart';
import 'widgets/order_card.dart';
import 'widgets/orders_hero.dart';
import 'widgets/orders_skeleton.dart';
import 'widgets/spotlight_card.dart';

/// الشاشة الرئيسية: الهيدر والشريط العلوي قطعة واحدة، والشريط يتلوّن عند التمرير.
class OrdersListScreen extends GetView<OrdersController> {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) => _OrdersBody(controller: controller);
}

class _OrdersBody extends StatefulWidget {
  const _OrdersBody({required this.controller});

  final OrdersController controller;

  @override
  State<_OrdersBody> createState() => _OrdersBodyState();
}

class _OrdersBodyState extends State<_OrdersBody> {
  final _scroll = ScrollController();

  OrdersController get controller => widget.controller;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barHeight = MediaQuery.paddingOf(context).top + kToolbarHeight;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: controller.refreshOrders,
              edgeOffset: barHeight,
              child: CustomScrollView(
                // حفظ موضع التمرير.
                key: const PageStorageKey('orders-list'),
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  Obx(() => SliverToBoxAdapter(child: _hero(barHeight))),
                  Obx(_offlineNotice),
                  Obx(_content),
                ],
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: _FloatingToolbar(scroll: _scroll, controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero(double topInset) {
    final spotlight = controller.spotlight;
    return OrdersHero(
      topInset: topInset,
      summary: controller.isLoading.value && !controller.hasData
          ? 'loading_orders'.tr
          : controller.heroSummary,
      pill: ConnectionPill(
        state: controller.bannerState,
        lastUpdatedLabel: controller.lastUpdatedLabel,
        ink: BrandColors.onGradient,
      ),
      spotlight: spotlight == null
          ? null
          : SpotlightCard(
              order: spotlight,
              now: controller.now.value,
              onTap: () => controller.openOrder(spotlight),
              onCallCourier: () => controller.callCourier(spotlight),
            ),
    );
  }

  Widget _offlineNotice() {
    final show = controller.bannerState == ConnectionBannerState.offline;
    final side = Responsive.sidePadding(context);
    return SliverPadding(
      padding: EdgeInsetsDirectional.fromSTEB(
        side,
        show ? BrandSpacing.md : 0,
        side,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AnimatedSize(
          duration: BrandMotion.base,
          curve: BrandMotion.curve,
          child: show
              ? OfflineCard(lastUpdatedLabel: controller.lastUpdatedLabel)
              : const SizedBox(width: double.infinity),
        ),
      ),
    );
  }

  Widget _content() {
    final error = controller.error.value;
    if (controller.isLoading.value && !controller.hasData) {
      final side = Responsive.sidePadding(context);
      return SliverPadding(
        padding: EdgeInsetsDirectional.fromSTEB(
          side,
          BrandSpacing.xl,
          side,
          BrandSpacing.xl,
        ),
        sliver: const SliverToBoxAdapter(child: OrdersSkeleton()),
      );
    }
    if (error != null && !controller.hasData) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ContentColumn(
          maxWidth: Responsive.stateMaxWidth,
          child: StateView(
            scrollable: false,
            illustration: error.isOffline
                ? BrandAssets.illustrationOffline
                : BrandAssets.illustrationError,
            title: error.title,
            message: error.message,
            actionLabel: 'retry'.tr,
            actionIcon: Icons.refresh_rounded,
            onAction: controller.retry,
          ),
        ),
      );
    }
    if (!controller.hasData) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ContentColumn(
          maxWidth: Responsive.stateMaxWidth,
          child: StateView(
            scrollable: false,
            illustration: BrandAssets.illustrationEmpty,
            title: 'empty_title'.tr,
            message: 'empty_subtitle'.tr,
            actionLabel: 'order_now'.tr,
            actionIcon: Icons.storefront_outlined,
            onAction: controller.orderNow,
          ),
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        ..._section('section_past'.tr, controller.pastOrders),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
              top: BrandSpacing.xxxl,
              bottom: BrandSpacing.xxl + MediaQuery.paddingOf(context).bottom,
            ),
            child: const Center(child: MakerMark()),
          ),
        ),
      ],
    );
  }

  List<Widget> _section(String label, List<OrderModel> orders) {
    if (orders.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: SectionHeader(label: label, count: orders.length),
      ),
      SliverPadding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: Responsive.sidePadding(context),
        ),
        sliver: SliverList.separated(
          itemCount: orders.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: BrandSpacing.cardGap),
          itemBuilder: (_, i) => StaggeredEntrance(
            key: ValueKey(orders[i].id),
            index: i,
            child: OrderCard(
              order: orders[i],
              onTap: () => controller.openOrder(orders[i]),
            ),
          ),
        ),
      ),
    ];
  }
}

class _FloatingToolbar extends StatelessWidget {
  const _FloatingToolbar({required this.scroll, required this.controller});

  final ScrollController scroll;
  final OrdersController controller;

  /// مسافة التمرير لتلوين الشريط وظهور العنوان.
  static const _solidAfter = 24.0;
  static const _titleFrom = 40.0;
  static const _titleTo = 80.0;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return AnimatedBuilder(
      animation: scroll,
      builder: (context, child) {
        final offset = scroll.hasClients ? scroll.offset : 0.0;
        final solid = (offset / _solidAfter).clamp(0.0, 1.0);
        final title = ((offset - _titleFrom) / (_titleTo - _titleFrom)).clamp(
          0.0,
          1.0,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            // نفس كحلي التدرّج.
            color: palette.gradientEnd.withValues(alpha: solid),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18 * solid),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _bar(context, title),
        );
      },
    );
  }

  Widget _bar(BuildContext context, double titleOpacity) {
    const ink = BrandColors.onGradient;
    final side = Responsive.sidePadding(context);
    return SafeArea(
      bottom: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: kToolbarHeight,
            child: Padding(
              // الأزرار لها هامش داخلي 8.
              padding: EdgeInsetsDirectional.fromSTEB(
                side,
                0,
                side - BrandSpacing.xs,
                0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    // للتطوير: ضغط مطوّل لمحاكاة الانقطاع.
                    onLongPress: kDebugMode
                        ? controller.toggleSimulatedOffline
                        : null,
                    child: const WasalLogo(height: 26, onColor: ink),
                  ),
                  const SizedBox(width: BrandSpacing.sm),
                  Expanded(
                    child: Opacity(
                      opacity: titleOpacity,
                      child: Text(
                        'orders_title'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: BrandTypography.h3,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ),
                  ),
                  const ThemeToggleButton(color: ink),
                  const SizedBox(width: BrandSpacing.xxs),
                  Obx(
                    () => _RefreshAction(
                      busy: controller.isRefreshing.value,
                      onPressed: controller.refreshOrders,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => AnimatedOpacity(
              // شريط تحميل أثناء التحديث فقط.
              opacity: controller.isRefreshing.value && controller.hasData
                  ? 1
                  : 0,
              duration: BrandMotion.fast,
              child: const LinearProgressIndicator(
                minHeight: 2,
                color: ink,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshAction extends StatelessWidget {
  const _RefreshAction({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const ink = BrandColors.onGradient;
    return IconButton(
      tooltip: 'refresh'.tr,
      onPressed: busy ? null : onPressed,
      style: IconButton.styleFrom(
        backgroundColor: ink.withValues(alpha: 0.08),
        disabledBackgroundColor: ink.withValues(alpha: 0.08),
      ),
      icon: AnimatedSwitcher(
        duration: BrandMotion.fast,
        child: busy
            ? const SizedBox.square(
                key: ValueKey('busy'),
                dimension: BrandIconography.md,
                child: CircularProgressIndicator(strokeWidth: 2, color: ink),
              )
            : const Icon(
                Icons.refresh_rounded,
                key: ValueKey('idle'),
                color: ink,
              ),
      ),
    );
  }
}
