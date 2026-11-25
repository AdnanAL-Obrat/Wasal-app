import 'package:evancode_task/core/ui/material.dart';

import '../constants/brand_tokens.dart';

/// ظهور عناصر القائمة بالتتابع مرة واحدة.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  // التأخير داخل الأنيميشن بدل Timer.
  late final Duration _delay =
      BrandMotion.stagger * widget.index.clamp(0, BrandMotion.staggerMaxItems);
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _delay + BrandMotion.slow,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _delay.inMicroseconds / _controller.duration!.inMicroseconds,
      1,
      curve: BrandMotion.curve,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

/// تأثير ضغط خفيف (تصغير 0.97).
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child});

  final Widget child;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: BrandMotion.fast,
        curve: BrandMotion.curve,
        child: widget.child,
      ),
    );
  }
}
