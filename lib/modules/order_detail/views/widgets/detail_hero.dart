import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/app_content.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/route_map.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/timeline_stage_model.dart';
import '../../controllers/delivery_progress.dart';
import 'stage_icons.dart';

/// ألوان الهيدر: تدرّج أثناء التوصيل، تيل عند الوصول، داكن عند الإلغاء.
class HeroScheme {
  const HeroScheme(this.background, this.foreground, [this.gradient]);

  /// اللون الأساسي.
  final Color background;
  final Color foreground;

  /// التدرّج إن وُجد.
  final Gradient? gradient;

  bool get isLight => foreground.computeLuminance() < 0.5;

  factory HeroScheme.of(BuildContext context, OrderStatus status) {
    final p = AppPalette.of(context);
    return switch (status) {
      OrderStatus.delivered => HeroScheme(p.primary, BrandColors.onPrimary),
      OrderStatus.cancelled => HeroScheme(p.inkHero, p.onInkHero),
      _ => HeroScheme(p.gradientEnd, p.onGradient, p.headerGradient),
    };
  }
}

/// محتوى هيدر التفاصيل: الرقم، العنوان، الوقت، الخريطة.
class DetailHero extends StatelessWidget {
  const DetailHero({
    super.key,
    required this.order,
    required this.now,
    required this.onCopyId,
  });

  final OrderModel order;
  final DateTime now;
  final VoidCallback onCopyId;

  @override
  Widget build(BuildContext context) {
    final scheme = HeroScheme.of(context, order.status);
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    // يختفي المحتوى عند الطي.
    final t = settings == null || settings.maxExtent == settings.minExtent
        ? 1.0
        : ((settings.currentExtent - settings.minExtent) /
                  (settings.maxExtent - settings.minExtent))
              .clamp(0.0, 1.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.background,
        gradient: scheme.gradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // المحتوى يبدأ تحت الشريط العلوي.
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + kToolbarHeight,
            ),
            child: Opacity(
              opacity: Curves.easeIn.transform(t),
              child: ClipRect(
                child: SingleChildScrollView(
                  reverse: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsetsDirectional.fromSTEB(
                    Responsive.sidePadding(context),
                    0,
                    Responsive.sidePadding(context),
                    BrandSpacing.xl,
                  ),
                  child: _content(context, scheme),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, HeroScheme scheme) {
    final ink = scheme.foreground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IdPill(id: order.id, ink: ink, onTap: onCopyId),
        const SizedBox(height: BrandSpacing.sm),
        Text(
          _headline,
          style: TextStyle(
            fontSize: BrandTypography.heroTitle,
            fontWeight: FontWeight.w700,
            height: 1.25,
            color: ink,
          ),
        ),
        const SizedBox(height: BrandSpacing.xxs),
        _StatusLine(order: order, now: now, ink: ink),
        const SizedBox(height: BrandSpacing.lg),
        RouteMap(
          progress: DeliveryProgress.routeFraction(order, now),
          ink: ink,
          ground: scheme.background,
          // أيقونة المرحلة الحالية.
          markerIcon: StageIcons.of(DeliveryProgress.currentStage(order)),
          live: !order.status.isFinal,
        ),
      ],
    );
  }

  String get _headline => switch (order.status) {
    OrderStatus.preparing => 'hero_preparing'.tr,
    OrderStatus.inTransit => 'hero_in_transit'.tr,
    OrderStatus.delivered => 'hero_delivered'.tr,
    OrderStatus.cancelled => 'hero_cancelled'.tr,
    OrderStatus.unknown => order.statusLabelAr,
  };
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.order,
    required this.now,
    required this.ink,
  });

  final OrderModel order;
  final DateTime now;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      fontSize: BrandTypography.bodyL,
      color: ink.withValues(alpha: 0.82),
    );
    if (order.status == OrderStatus.delivered ||
        order.status == OrderStatus.cancelled) {
      final stage = order.status == OrderStatus.delivered
          ? DeliveryStage.delivered
          : DeliveryStage.cancelled;
      final at = order.timeline
          .where((t) => t.stage == stage)
          .map((t) => t.timestamp)
          .firstOrNull;
      final key = order.status == OrderStatus.delivered
          ? 'delivered_at'
          : 'cancelled_at';
      return Text(
        at == null
            ? AppFormatters.friendlyDate(order.date)
            : key.trParams({'time': AppFormatters.timeOf(at)}),
        style: muted,
      );
    }
    final window = DeliveryProgress.etaWindow(order.estimatedDelivery, now);
    if (window?.kind != EtaKind.range) {
      return Text(
        DeliveryProgress.etaText(order.estimatedDelivery, now) ?? '',
        style: muted,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${window!.from}–${window.to}',
          style: TextStyle(
            fontSize: BrandTypography.display,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: ink,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: BrandSpacing.xs),
        Flexible(child: Text('minutes'.tr, style: muted)),
      ],
    );
  }
}

class _IdPill extends StatelessWidget {
  const _IdPill({required this.id, required this.ink, required this.onTap});

  final String id;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      hint: 'tap_to_copy'.tr,
      child: Material(
        color: ink.withValues(alpha: 0.1),
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: BrandSpacing.sm,
              vertical: BrandSpacing.xxs + 1,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppContent.orderNumber(id),
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: BrandTypography.caption,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: ink,
                  ),
                ),
                const SizedBox(width: BrandSpacing.xxs + 2),
                Icon(Icons.copy_rounded, size: 13, color: ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
