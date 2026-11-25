import 'package:evancode_task/core/ui/material.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';

/// شكل فاتورة بفواصل مثقّبة.
class Ticket extends StatelessWidget {
  const Ticket({super.key, required this.sections});

  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(BrandRadius.lg),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: BrandElevation.shadowBlur,
            offset: const Offset(0, BrandElevation.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const _Perforation(),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: BrandSpacing.md,
                vertical: BrandSpacing.sm,
              ),
              child: sections[i],
            ),
          ],
        ],
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation();

  static const _notch = 10.0;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return SizedBox(
      height: _notch * 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: _notch + BrandSpacing.xs,
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 1),
              painter: _DashPainter(palette.border),
            ),
          ),
          PositionedDirectional(start: -_notch, child: _hole(palette)),
          PositionedDirectional(end: -_notch, child: _hole(palette)),
        ],
      ),
    );
  }

  Widget _hole(AppPalette palette) => Container(
    width: _notch * 2,
    height: _notch * 2,
    decoration: BoxDecoration(
      color: palette.background,
      shape: BoxShape.circle,
    ),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var x = 0.0; x < size.width; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}
