import 'package:evancode_task/core/ui/material.dart';

import '../constants/brand_tokens.dart';

/// زخرفة المسار المنقّط خلف الهيدر.
class RoutePattern extends StatelessWidget {
  const RoutePattern({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _PatternPainter(
          color: color,
          rtl: Directionality.of(context) == TextDirection.rtl,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  _PatternPainter({required this.color, required this.rtl});

  final Color color;
  final bool rtl;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    // يبتعد عن جهة العنوان.
    double x(double fx) => rtl ? w * fx : w * (1 - fx);
    final path = Path()
      ..moveTo(x(1.05), h * 0.95)
      ..cubicTo(x(0.75), h * 1.0, x(0.55), h * 0.15, x(0.18), h * 0.22);
    final paint = Paint()..color = color;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += BrandRoute.dotPitch * 2.2) {
        final pos = metric.getTangentForOffset(d)?.position;
        if (pos != null) {
          canvas.drawCircle(pos, BrandRoute.dotRadius * 1.6, paint);
        }
      }
      final end = metric.getTangentForOffset(metric.length)?.position;
      if (end != null) {
        canvas.drawCircle(end, BrandRoute.destinationRadius * 1.6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.color != color || old.rtl != rtl;
}
