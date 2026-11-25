import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter/rendering.dart';

/// انتقال الثيم بدائرة تتسع من مكان الضغط.
class ThemeReveal extends StatefulWidget {
  const ThemeReveal({super.key, required this.child});

  final Widget child;

  @override
  State<ThemeReveal> createState() => ThemeRevealState();
}

class ThemeRevealState extends State<ThemeReveal>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 650);

  final _boundary = GlobalKey();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  ui.Image? _snapshot;
  Offset _origin = Offset.zero;

  Future<void> reveal({
    required Offset origin,
    required VoidCallback apply,
  }) async {
    if (_controller.isAnimating) return;
    final image = MediaQuery.of(context).disableAnimations
        ? null
        : await _capture();
    if (image == null) {
      apply();
      return;
    }
    setState(() {
      _snapshot = image;
      _origin = origin;
    });
    apply();
    await _controller.forward(from: 0);
    if (!mounted) return;
    setState(() => _snapshot = null);
    image.dispose();
  }

  Future<ui.Image?> _capture() async {
    final boundary =
        _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || boundary.debugNeedsPaint) return null;
    try {
      return await boundary.toImage(
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
    } on Exception catch (e) {
      debugPrint('[ThemeReveal] snapshot failed, switching instantly: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        RepaintBoundary(key: _boundary, child: widget.child),
        if (snapshot != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _curve,
                builder: (context, child) => ClipPath(
                  clipper: _HoleClipper(_origin, _curve.value),
                  child: child,
                ),
                child: RawImage(
                  image: snapshot,
                  scale: MediaQuery.devicePixelRatioOf(context),
                  alignment: Alignment.topLeft,
                  fit: BoxFit.none,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// الشاشة القديمة مع دائرة تتسع.
class _HoleClipper extends CustomClipper<Path> {
  _HoleClipper(this.origin, this.progress);

  final Offset origin;
  final double progress;

  @override
  Path getClip(Size size) {
    final corners = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ];
    final maxRadius = corners
        .map((c) => (c - origin).distance)
        .reduce(math.max);
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: origin, radius: maxRadius * progress));
  }

  @override
  bool shouldReclip(_HoleClipper old) =>
      old.progress != progress || old.origin != origin;
}
