import 'package:evancode_task/core/ui/material.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';
import 'motion.dart';
import 'spread_row.dart';

/// كرت الهوية: زوايا ناعمة وحد رفيع وظل خفيف.
class BrandCard extends StatelessWidget {
  const BrandCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(BrandSpacing.md),
    this.radius = BrandRadius.lg,
    this.raised = false,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// ظل أعمق للكرت الرئيسي.
  final bool raised;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final shape = BorderRadius.circular(radius);
    final card = Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: shape,
          boxShadow: [
            BoxShadow(
              color: raised
                  ? palette.primary.withValues(alpha: 0.10)
                  : palette.shadow,
              blurRadius: raised ? 20 : BrandElevation.shadowBlur,
              offset: Offset(0, raised ? 6 : BrandElevation.shadowOffsetY),
            ),
          ],
        ),
        child: Material(
          color: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: shape,
            side: BorderSide(color: palette.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
    return onTap == null ? card : Pressable(child: card);
  }
}

/// قسم بعنوان وأيقونة (صفحة التفاصيل).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsetsDirectional.all(BrandSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(title: title, icon: icon, trailing: trailing),
          const SizedBox(height: BrandSpacing.md),
          child,
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final label = Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: palette.secondarySoft,
            borderRadius: BorderRadius.circular(BrandRadius.sm + 2),
          ),
          child: Icon(
            icon,
            size: BrandIconography.md,
            color: palette.secondary,
          ),
        ),
        const SizedBox(width: BrandSpacing.sm),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
      ],
    );
    final action = trailing;
    // يصغر فقط إذا ضاقت المساحة.
    return action == null ? label : SpreadRow(leading: label, trailing: action);
  }
}
