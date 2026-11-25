import 'dart:ui' show PathMetric;

import 'package:evancode_task/core/ui/material.dart';

import '../constants/brand_tokens.dart';

/// خريطة رمزية للتوصيل: المطعم ← المسار ← المنزل.
class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.progress,
    required this.ink,
    required this.ground,
    required this.markerIcon,
    this.live = true,
    this.height = 104,
  });

  final double progress;

  /// لون الخط والأيقونات.
  final Color ink;

  /// لون الهيدر خلف الأيقونات.
  final Color ground;
  final IconData markerIcon;

  /// نبض أثناء حركة الطلب.
  final bool live;
  final double height;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap>
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
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.live != widget.live) _syncPulse();
  }

  void _syncPulse() {
    final animate = widget.live && !MediaQuery.of(context).disableAnimations;
    if (animate) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, box) {
          final size = Size(box.maxWidth, widget.height);
          final metric = _routePath(size, rtl).computeMetrics().first;
          final at = metric.length * widget.progress.clamp(0.0, 1.0);
          final start = metric.getTangentForOffset(0)!.position;
          final end = metric.getTangentForOffset(metric.length)!.position;
          final here = metric.getTangentForOffset(at)!.position;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MapPainter(
                    metric: metric,
                    travelled: at,
                    ink: widget.ink,
                    pulse: _pulse,
                    here: here,
                    showPulse: widget.live,
                  ),
                ),
              ),
              if (widget.progress > 0.02)
                _glyph(start, Icons.restaurant_rounded, 30),
              _glyph(end, Icons.home_rounded, 30),
              _marker(here),
            ],
          );
        },
      ),
    );
  }

  /// أيقونة المرحلة الحالية.
  Widget _marker(Offset c) {
    const size = 40.0;
    return Positioned(
      left: c.dx - size / 2,
      top: c.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.ink,
          shape: BoxShape.circle,
          border: Border.all(color: widget.ground, width: 3),
        ),
        child: AnimatedSwitcher(
          duration: BrandMotion.base,
          transitionBuilder: (child, a) =>
              ScaleTransition(scale: a, child: child),
          child: Icon(
            widget.markerIcon,
            key: ValueKey(widget.markerIcon),
            size: size * 0.55,
            color: widget.ground,
          ),
        ),
      ),
    );
  }

  Widget _glyph(Offset c, IconData icon, double size) {
    return Positioned(
      left: c.dx - size / 2,
      top: c.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: widget.ink, shape: BoxShape.circle),
        child: Icon(icon, size: size * 0.55, color: widget.ground),
      ),
    );
  }

  /// منحنى المسار من المطعم إلى المنزل.
  static Path _routePath(Size s, bool rtl) {
    const pad = 22.0;
    double x(double fx) => rtl ? s.width - fx : fx;
    final w = s.width;
    return Path()
      ..moveTo(x(pad), s.height * 0.72)
      ..cubicTo(
        x(w * 0.38),
        s.height * -0.05,
        x(w * 0.55),
        s.height * 1.05,
        x(w - pad),
        s.height * 0.3,
      );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.metric,
    required this.travelled,
    required this.ink,
    required this.pulse,
    required this.here,
    required this.showPulse,
  }) : super(repaint: pulse);

  final PathMetric metric;
  final double travelled;
  final Color ink;
  final Animation<double> pulse;
  final Offset here;
  final bool showPulse;

  @override
  void paint(Canvas canvas, Size size) {
    final dots = Paint()..color = ink.withValues(alpha: 0.4);
    for (var d = travelled; d < metric.length; d += BrandRoute.dotPitch) {
      final p = metric.getTangentForOffset(d)?.position;
      if (p != null) canvas.drawCircle(p, BrandRoute.dotRadius + 0.4, dots);
    }
    canvas.drawPath(
      metric.extractPath(0, travelled),
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = BrandRoute.stroke + 1
        ..strokeCap = StrokeCap.round,
    );
    if (showPulse) {
      final t = pulse.value;
      canvas.drawCircle(
        here,
        20 + 16 * t,
        Paint()..color = ink.withValues(alpha: 0.22 * (1 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.travelled != travelled || old.ink != ink || old.here != here;
}
