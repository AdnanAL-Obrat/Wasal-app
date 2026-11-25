import 'package:get/get.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/timeline_stage_model.dart';

enum StepState { completed, active, upcoming, cancelled }

enum EtaKind { range, soon, late }

class EtaWindow {
  const EtaWindow(this.kind, {this.from, this.to});

  final EtaKind kind;
  final int? from;
  final int? to;
}

/// سطر واحد في مراحل التوصيل.
class TimelineStep {
  const TimelineStep({
    required this.stage,
    required this.label,
    required this.state,
    this.timestamp,
    this.note,
  });

  final DeliveryStage stage;
  final String label;
  final StepState state;
  final DateTime? timestamp;

  /// الوقت المتوقع أو سبب الإلغاء.
  final String? note;
}

/// تحويل الطلب إلى مراحل للعرض.
abstract final class DeliveryProgress {
  static List<TimelineStep> stepsFor(OrderModel order, {DateTime? now}) =>
      order.status == OrderStatus.cancelled
      ? _cancelledSteps(order)
      : _flowSteps(order, now ?? DateTime.now());

  static List<TimelineStep> _flowSteps(OrderModel order, DateTime now) {
    final reached = DeliveryStage.flow.map((s) => _entry(order, s)).toList();
    final delivered = order.status == OrderStatus.delivered;
    final activeIndex = delivered
        ? DeliveryStage.flow.length
        : reached.lastIndexWhere((e) => e?.isCompleted ?? false).clamp(0, 99);

    return [
      for (var i = 0; i < DeliveryStage.flow.length; i++)
        TimelineStep(
          stage: DeliveryStage.flow[i],
          label: _label(DeliveryStage.flow[i]),
          timestamp: reached[i]?.timestamp,
          state: i < activeIndex
              ? StepState.completed
              : (i == activeIndex ? StepState.active : StepState.upcoming),
          note: i == activeIndex ? etaText(order.estimatedDelivery, now) : null,
        ),
    ];
  }

  /// المراحل قبل الإلغاء ثم الإلغاء.
  static List<TimelineStep> _cancelledSteps(OrderModel order) {
    // المراحل المعروضة فقط.
    final completed = order.timeline.where(
      (t) => t.isCompleted && DeliveryStage.flow.contains(t.stage),
    );
    final cancelEntry = _entry(order, DeliveryStage.cancelled);
    return [
      for (final t in completed)
        TimelineStep(
          stage: t.stage,
          label: _label(t.stage),
          timestamp: t.timestamp,
          state: StepState.completed,
        ),
      TimelineStep(
        stage: DeliveryStage.cancelled,
        label: _label(DeliveryStage.cancelled),
        timestamp: cancelEntry?.timestamp,
        state: StepState.cancelled,
        note: order.cancellationReason,
      ),
    ];
  }

  /// نص الوقت المتوقع (كل 5 دقائق).
  static String? etaText(DateTime? eta, DateTime now) {
    final window = etaWindow(eta, now);
    return switch (window) {
      null => null,
      EtaWindow(kind: EtaKind.late) => 'eta_late'.tr,
      EtaWindow(kind: EtaKind.soon) => 'eta_soon'.tr,
      EtaWindow(:final from, :final to) => 'eta_range'.trParams({
        'from': '$from',
        'to': '$to',
      }),
    };
  }

  /// الوقت المتوقع للأرقام الكبيرة.
  static EtaWindow? etaWindow(DateTime? eta, DateTime now) {
    if (eta == null) return null;
    final minutes = eta.difference(now).inMinutes;
    if (minutes < 0) return const EtaWindow(EtaKind.late);
    if (minutes < 5) return const EtaWindow(EtaKind.soon);
    final from = (minutes ~/ 5) * 5;
    return EtaWindow(EtaKind.range, from: from, to: from + 5);
  }

  /// آخر مرحلة تم الوصول إليها.
  static int reachedIndex(OrderModel order) {
    if (order.status == OrderStatus.delivered) {
      return DeliveryStage.flow.length - 1;
    }
    var reached = 0;
    for (var i = 0; i < DeliveryStage.flow.length; i++) {
      if (_entry(order, DeliveryStage.flow[i])?.isCompleted ?? false) {
        reached = i;
      }
    }
    return reached;
  }

  /// موقع المندوب على الخريطة (0..1): في المطعم حتى يخرج، ثم يتقدّم مع الوقت.
  static double routeFraction(OrderModel order, DateTime now) {
    if (order.status == OrderStatus.delivered) return 1;
    final stage = currentStage(order);
    if (stage != DeliveryStage.inTransit) return 0;
    final left = _entry(order, DeliveryStage.inTransit)?.timestamp;
    final eta = order.estimatedDelivery;
    if (left == null || eta == null || !eta.isAfter(left)) return 0.5;
    final ratio =
        now.difference(left).inSeconds / eta.difference(left).inSeconds;
    return 0.12 + 0.8 * ratio.clamp(0.0, 1.0);
  }

  /// المرحلة الحالية.
  static DeliveryStage currentStage(OrderModel order) {
    if (order.status == OrderStatus.cancelled) return DeliveryStage.cancelled;
    return DeliveryStage.flow[reachedIndex(order)];
  }

  static TimelineStageModel? _entry(OrderModel order, DeliveryStage stage) {
    for (final t in order.timeline) {
      if (t.stage == stage) return t;
    }
    return null;
  }

  static String _label(DeliveryStage stage) => 'stage_${stage.key}'.tr;
}
