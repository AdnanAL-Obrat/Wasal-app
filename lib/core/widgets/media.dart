import 'dart:math' as math;

import 'package:evancode_task/core/ui/material.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';

/// صورة بحجم العرض مع ظهور تدريجي وبديل عند الفشل.
class BrandImage extends StatelessWidget {
  const BrandImage({
    super.key,
    required this.path,
    required this.size,
    this.radius = BrandRadius.md,
    this.circle = false,
    this.background,
    this.fallbackIcon = Icons.restaurant_rounded,
    this.semanticLabel,
  });

  final String? path;
  final double size;
  final double radius;
  final bool circle;
  final Color? background;
  final IconData fallbackIcon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final shape = circle
        ? const ShapeDecoration(shape: CircleBorder())
        : ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          );
    return SizedBox.square(
      dimension: size,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape.shape),
        child: ColoredBox(
          color: background ?? palette.skeletonBase,
          child: _image(context, palette),
        ),
      ),
    );
  }

  Widget _image(BuildContext context, AppPalette palette) {
    final source = path;
    final fallback = Center(
      child: Icon(
        fallbackIcon,
        size: size * 0.45,
        color: palette.textSecondary.withValues(alpha: 0.6),
      ),
    );
    if (source == null || source.isEmpty) return fallback;
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    final ImageProvider provider = source.startsWith('http')
        ? NetworkImage(source)
        : AssetImage(source);
    return Image(
      image: ResizeImage(
        provider,
        width: px,
        height: px,
        policy: ResizeImagePolicy.fit,
      ),
      fit: BoxFit.cover,
      width: size,
      height: size,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (_, _, _) => fallback,
      frameBuilder: (_, child, frame, syncLoaded) {
        if (syncLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: BrandMotion.base,
          curve: BrandMotion.curve,
          child: child,
        );
      },
    );
  }
}

/// شعار المطعم على خلفية بيضاء مع شارة اختيارية.
class StoreLogo extends StatelessWidget {
  const StoreLogo({
    super.key,
    required this.path,
    this.size = 48,
    this.badge,
    this.semanticLabel,
  });

  final String? path;
  final double size;
  final Widget? badge;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final radius = size * 0.28;
    final tile = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
      ),
      child: BrandImage(
        path: path,
        size: size,
        radius: radius,
        background: Colors.white,
        fallbackIcon: Icons.storefront_rounded,
        semanticLabel: semanticLabel,
      ),
    );
    final mark = badge;
    if (mark == null) return tile;
    return SizedBox.square(
      dimension: size + 6,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          tile,
          PositionedDirectional(bottom: 0, end: 0, child: mark),
        ],
      ),
    );
  }
}

/// صور الأطباق متداخلة مع «+n» للباقي.
class FoodStack extends StatelessWidget {
  const FoodStack({
    super.key,
    required this.images,
    this.size = 28,
    this.max = 3,
  });

  final List<String?> images;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final shown = images.take(max).toList();
    final extra = images.length - shown.length;
    final count = shown.length + (extra > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();
    final step = size * 0.62;
    final ring = math.max(2.0, size * 0.08);
    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < count; i++)
            PositionedDirectional(
              start: step * i,
              child: Container(
                width: size,
                height: size,
                padding: EdgeInsets.all(ring),
                decoration: BoxDecoration(
                  color: palette.surface,
                  shape: BoxShape.circle,
                ),
                child: i < shown.length
                    ? BrandImage(
                        path: shown[i],
                        size: size - ring * 2,
                        circle: true,
                        fallbackIcon: Icons.lunch_dining_rounded,
                      )
                    : _More(extra: extra, size: size - ring * 2),
              ),
            ),
        ],
      ),
    );
  }
}

class _More extends StatelessWidget {
  const _More({required this.extra, required this.size});

  final int extra;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: palette.secondarySoft,
        shape: BoxShape.circle,
      ),
      child: Text(
        '+$extra',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          color: palette.secondary,
        ),
      ),
    );
  }
}
