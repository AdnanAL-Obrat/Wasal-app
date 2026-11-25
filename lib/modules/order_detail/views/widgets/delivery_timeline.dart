import 'package:evancode_task/core/ui/material.dart' hide StepState;
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/timeline_stage_model.dart';
import '../../controllers/delivery_progress.dart';
import 'stage_icons.dart';

/// مراحل التوصيل: تيل = تم، كحلي = الآن، رمادي = قادم، أحمر = ملغي.
class DeliveryTimeline extends StatelessWidget {
  const DeliveryTimeline({super.key, required this.steps});

  final List<TimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            isLast: i == steps.length - 1,
            nextState: i + 1 < steps.length ? steps[i + 1].state : null,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.nextState,
  });

  final TimelineStep step;
  final bool isLast;
  final StepState? nextState;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                _StepDot(state: step.state, stage: step.stage),
                if (!isLast)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: BrandSpacing.xxs,
                      ),
                      child: CustomPaint(
                        size: const Size(BrandRoute.stroke, double.infinity),
                        painter: _ConnectorPainter(
                          color: _connectorColor(palette),
                          // الطريق القادم منقّط.
                          dotted: nextState == StepState.upcoming,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: BrandSpacing.sm),
          Expanded(
            child: _StepText(step: step, isLast: isLast),
          ),
        ],
      ),
    );
  }

  // لون الخط حسب المرحلة.
  Color _connectorColor(AppPalette p) => switch (nextState) {
    StepState.completed || StepState.active => p.statusDelivered,
    StepState.cancelled => p.statusCancelled,
    _ => p.border,
  };
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.state, required this.stage});

  final StepState state;
  final DeliveryStage stage;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    // لكل مرحلة أيقونتها، واللون يدل على الحالة.
    final glyph = StageIcons.of(stage);
    final (Color fill, Color icon) = switch (state) {
      StepState.completed => (p.statusDelivered, BrandColors.onPrimary),
      StepState.active => (
        p.secondary,
        Theme.of(context).colorScheme.onSecondary,
      ),
      StepState.cancelled => (p.statusCancelled, Colors.white),
      StepState.upcoming => (p.border, p.textSecondary),
    };
    return AnimatedContainer(
      duration: BrandMotion.base,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        boxShadow: state == StepState.active
            ? [
                BoxShadow(
                  color: p.secondary.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Icon(glyph, size: BrandIconography.sm, color: icon),
    );
  }
}

class _StepText extends StatelessWidget {
  const _StepText({required this.step, required this.isLast});

  final TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    final isActive = step.state == StepState.active;
    final isUpcoming = step.state == StepState.upcoming;
    final isCancelled = step.state == StepState.cancelled;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 3,
        bottom: isLast ? 0 : BrandSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.label,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: isActive || isCancelled
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isUpcoming
                        ? p.textSecondary
                        : (isCancelled ? p.statusCancelledFg : p.textPrimary),
                  ),
                ),
              ),
              if (step.timestamp != null)
                Text(
                  AppFormatters.timeOf(step.timestamp!),
                  style: text.bodySmall,
                ),
            ],
          ),
          if (isActive) _ActiveTag(note: step.note),
          if (isCancelled && step.note != null) _CancelReason(step.note!),
        ],
      ),
    );
  }
}

class _ActiveTag extends StatelessWidget {
  const _ActiveTag({this.note});

  final String? note;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      margin: const EdgeInsetsDirectional.only(top: BrandSpacing.xxs),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: BrandSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: p.primarySoft,
        borderRadius: BorderRadius.circular(BrandRadius.sm),
      ),
      child: Text(
        note ?? 'stage_current'.tr,
        style: TextStyle(
          fontSize: BrandTypography.caption,
          fontWeight: FontWeight.w600,
          color: p.primaryDeep,
        ),
      ),
    );
  }
}

class _CancelReason extends StatelessWidget {
  const _CancelReason(this.reason);

  final String reason;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.only(top: BrandSpacing.xs),
      padding: const EdgeInsetsDirectional.all(BrandSpacing.sm),
      decoration: BoxDecoration(
        color: p.statusCancelledBg,
        borderRadius: BorderRadius.circular(BrandRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cancellation_reason'.tr,
            style: TextStyle(
              fontSize: BrandTypography.caption,
              fontWeight: FontWeight.w700,
              color: p.statusCancelledFg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            reason,
            style: TextStyle(
              fontSize: BrandTypography.bodyM,
              height: BrandTypography.lineHeightBody,
              color: p.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.color, required this.dotted});

  final Color color;
  final bool dotted;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = BrandRoute.stroke - 1
      ..strokeCap = StrokeCap.round;
    if (!dotted) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      return;
    }
    for (
      var y = BrandRoute.dotRadius;
      y < size.height;
      y += BrandRoute.dotPitch
    ) {
      canvas.drawCircle(Offset(x, y), BrandRoute.dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.color != color || old.dotted != dotted;
}
