import 'package:evancode_task/core/ui/material.dart';

import '../constants/brand_tokens.dart';

/// شريط تقدّم التوصيل: خط متصل للمنجز ومنقّط للباقي.
class RouteProgress extends StatefulWidget {
  const RouteProgress({
    super.key,
    required this.stages,
    required this.reached,
    required this.color,
    required this.trackColor,
    this.holeColor,
    this.live = true,
    this.height = 18,
  });

  /// عدد المراحل.
  final int stages;

  /// آخر مرحلة تم الوصول إليها.
  final int reached;
  final Color color;
  final Color trackColor;

  /// لون داخل المراحل القادمة.
  final Color? holeColor;

  /// نبض المرحلة الحالية.
  final bool live;
  final double height;

  @override
  State<RouteProgress> createState() => _RouteProgressState();
}

class _RouteProgressState extends State<RouteProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: BrandMotion.pulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(RouteProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (widget.live && !reduceMotion) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.value = 0;
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: CustomPaint(
        painter: _RoutePainter(
          stages: widget.stages,
          reached: widget.reached,
          color: widget.color,
          track: widget.trackColor,
          hole: widget.holeColor,
          live: widget.live,
          pulse: _pulse,
          rtl: Directionality.of(context) == TextDirection.rtl,
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.stages,
    required this.reached,
    required this.color,
    required this.track,
    required this.hole,
    required this.live,
    required this.pulse,
    required this.rtl,
  }) : super(repaint: pulse);

  final int stages;
  final int reached;
  final Color color;
  final Color track;
  final Color? hole;
  final bool live;
  final Animation<double> pulse;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = BrandRoute.haloRadius;
    final y = size.height / 2;
    final span = size.width - inset * 2;
    double xAt(double t) =>
        rtl ? size.width - inset - t * span : inset + t * span;
    double tOf(int i) => stages <= 1 ? 0 : i / (stages - 1);

    _dottedTrack(canvas, xAt, y, span);
    final reachedT = tOf(reached.clamp(0, stages - 1));
    canvas.drawLine(
      Offset(xAt(0), y),
      Offset(xAt(reachedT), y),
      Paint()
        ..color = color
        ..strokeWidth = BrandRoute.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < stages; i++) {
      _node(canvas, Offset(xAt(tOf(i)), y), i);
    }
  }

  void _dottedTrack(
    Canvas canvas,
    double Function(double) xAt,
    double y,
    double span,
  ) {
    final paint = Paint()..color = track;
    final count = (span / BrandRoute.dotPitch).floor();
    for (var i = 0; i <= count; i++) {
      canvas.drawCircle(Offset(xAt(i / count), y), BrandRoute.dotRadius, paint);
    }
  }

  void _node(Canvas canvas, Offset c, int i) {
    final isDestination = i == stages - 1;
    final isReached = i <= reached;
    final radius = isDestination
        ? BrandRoute.destinationRadius
        : BrandRoute.nodeRadius;
    if (i == reached && live) {
      final t = pulse.value;
      canvas.drawCircle(
        c,
        radius + (BrandRoute.haloRadius - radius) * t,
        Paint()..color = color.withValues(alpha: 0.35 * (1 - t)),
      );
    }
    canvas.drawCircle(c, radius, Paint()..color = isReached ? color : track);
    if (!isReached && hole != null) {
      // المراحل القادمة مفرّغة.
      canvas.drawCircle(c, radius - 2, Paint()..color = hole!);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.reached != reached ||
      old.color != color ||
      old.track != track ||
      old.hole != hole ||
      old.live != live ||
      old.rtl != rtl;
}
