import 'package:evancode_task/core/ui/material.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';

/// توقيع المطوّر أسفل الشاشة: ملوّن في الفاتح، أبيض في الغامق.
class MakerMark extends StatelessWidget {
  const MakerMark({super.key, this.height = 28});

  static const _color = 'assets/brand/obrat_logo_color.png';
  static const _white = 'assets/brand/obrat_logo_white.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: 'OBRAT',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _line(palette),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BrandSpacing.sm,
                ),
                child: Text(
                  'تطوير',
                  style: text.labelSmall?.copyWith(
                    color: palette.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              _line(palette),
            ],
          ),
          const SizedBox(height: BrandSpacing.sm),
          AnimatedSwitcher(
            duration: BrandMotion.base,
            child: Image.asset(
              dark ? _white : _color,
              key: ValueKey(dark),
              height: height,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) => SizedBox(height: height),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(AppPalette palette) =>
      Container(width: 32, height: 1, color: palette.border);
}
