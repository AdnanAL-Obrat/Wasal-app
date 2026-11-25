import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';

/// شاشة حالة: فارغ / خطأ / بدون اتصال.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.scrollable = true,
  });

  final String illustration;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// false إذا كان الأب قابلًا للتمرير.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: BrandSpacing.xxl,
          vertical: BrandSpacing.xl,
        ),
        child: Center(child: _content(context)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: BrandSpacing.xxl,
          vertical: BrandSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight - BrandSpacing.xl * 2,
          ),
          child: Center(child: _content(context)),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final palette = AppPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          illustration,
          width: BrandIconography.illustration,
          height: BrandIconography.illustration,
          theme: SvgTheme(currentColor: palette.textSecondary),
          excludeFromSemantics: true,
        ),
        const SizedBox(height: BrandSpacing.xl),
        Text(title, style: text.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: BrandSpacing.xs),
        Text(
          message,
          style: text.bodyMedium?.copyWith(color: palette.textSecondary),
          textAlign: TextAlign.center,
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: BrandSpacing.xl),
          FilledButton.icon(
            onPressed: onAction,
            icon: Icon(actionIcon ?? Icons.refresh_rounded),
            label: Text(actionLabel!),
          ),
        ],
      ],
    );
  }
}
