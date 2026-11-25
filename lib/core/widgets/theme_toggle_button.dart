import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../constants/brand_tokens.dart';
import '../services/theme_service.dart';

/// زر الثيم: الشمس تتحول إلى هلال.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.color});

  /// لون الأيقونة.
  final Color color;

  static const _morph = Duration(milliseconds: 550);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: (isDark ? 'theme_to_light' : 'theme_to_dark').tr,
      style: IconButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.08),
      ),
      onPressed: () => _toggle(context, isDark),
      icon: TweenAnimationBuilder<double>(
        tween: Tween(end: isDark ? 1 : 0),
        duration: _morph,
        curve: Curves.easeInOutBack,
        builder: (_, t, _) => CustomPaint(
          size: const Size.square(BrandIconography.lg),
          painter: _SunMoonPainter(progress: t, color: color),
        ),
      ),
    );
  }

  void _toggle(BuildContext context, bool isDark) {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? Offset.zero
        : box.localToGlobal(box.size.center(Offset.zero));
    Get.find<ThemeService>().toggle(isDark: isDark, origin: origin);
  }
}

/// 0 = شمس، 1 = هلال.
class _SunMoonPainter extends CustomPainter {
  _SunMoonPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final t = progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-progress * math.pi / 2);
    canvas.translate(-c.dx, -c.dy);
    _rays(canvas, c, 1 - t);
    _body(canvas, size, c, t);
    canvas.restore();
  }

  void _rays(Canvas canvas, Offset c, double amount) {
    if (amount <= 0) return;
    final paint = Paint()
      ..color = color.withValues(alpha: amount)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final dir = Offset.fromDirection(i * math.pi / 4);
      const inner = 8.0;
      canvas.drawLine(c + dir * inner, c + dir * (inner + 2.6 * amount), paint);
    }
  }

  void _body(Canvas canvas, Size size, Offset c, double t) {
    final radius = ui.lerpDouble(4.6, 8.2, t)!;
    // طبقة لقص الهلال.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawCircle(c, radius, Paint()..color = color);
    final shift = ui.lerpDouble(radius * 2.4, radius * 0.62, t)!;
    canvas.drawCircle(
      c + Offset(shift, -shift),
      radius * 0.86,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SunMoonPainter old) =>
      old.progress != progress || old.color != color;
}
