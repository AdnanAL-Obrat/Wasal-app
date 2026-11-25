import 'dart:math' as math;

import 'package:evancode_task/core/ui/material.dart';

import '../constants/brand_tokens.dart';

/// فئات عرض الشاشة.
enum ScreenSize { compact, medium, expanded }

/// إعدادات التجاوب: عمود محتوى واحد بعرض أقصى ويتوسّط الشاشات الكبيرة.
abstract final class Responsive {
  static const double mediumFrom = 600;
  static const double expandedFrom = 1024;

  /// أقصى عرض للمحتوى.
  static const double contentMaxWidth = 680;

  /// أقصى عرض لشاشات الحالة (فارغ/خطأ).
  static const double stateMaxWidth = 420;

  /// أقصى تكبير للخط.
  static const double maxTextScale = 1.35;

  static ScreenSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= expandedFrom) return ScreenSize.expanded;
    if (width >= mediumFrom) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  /// هامش الجانب: 16 جوال، 24 تابلت، 32 شاشة كبيرة.
  static double gutter(BuildContext context) => switch (sizeOf(context)) {
    ScreenSize.compact => BrandSpacing.screenGutter,
    ScreenSize.medium => BrandSpacing.xl,
    ScreenSize.expanded => BrandSpacing.xxl,
  };

  /// الهامش الجانبي الفعلي حسب عرض الشاشة.
  static double sidePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return math.max(gutter(context), (width - contentMaxWidth) / 2);
  }

  /// ارتفاع هيدر التفاصيل، ويزيد مع تكبير الخط.
  static double heroHeight(BuildContext context) {
    const content = 276.0; // ارتفاع المحتوى بخط عادي
    const textPart = 112.0; // الجزء النصي منه
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return kToolbarHeight + content + textPart * (scale - 1);
  }
}

/// يتوسّط المحتوى بعرض أقصى.
class ContentColumn extends StatelessWidget {
  const ContentColumn({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
