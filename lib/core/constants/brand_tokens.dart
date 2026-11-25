// «وصّل» — رموز الهوية البصرية.
// المرجع الوحيد للألوان والمقاسات والحركة؛ لا قيم ثابتة داخل الويدجتات.

import 'dart:ui' show Color;

import 'package:flutter/animation.dart' show Curve, Curves;

/// ألوان الوضع الفاتح — تيل وكحلي.
abstract final class BrandColors {
  // ── الأساسية ─────────────────────────────────────────────────────────────
  /// التيل: الشعار والأزرار والمراحل المكتملة.
  static const Color primary = Color(0xFF2CB99A);

  /// تيل غامق للنصوص والروابط.
  static const Color primaryDeep = Color(0xFF14735C);

  /// تيل فاتح للخلفيات.
  static const Color primarySoft = Color(0xFFE3F6F1);

  /// لون النص فوق التيل (كحلي؛ الأبيض تباينه ضعيف).
  static const Color onPrimary = Color(0xFF073F5D);

  /// الكحلي: الهيدر والعناوين والمرحلة الحالية.
  static const Color secondary = Color(0xFF073F5D);
  static const Color secondarySoft = Color(0xFFE4EEF3);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── التدرّج (للهيدر فقط) ───────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF2CB99A);
  static const Color gradientMid = Color(0xFF197A7B);
  static const Color gradientEnd = Color(0xFF073F5D);

  /// النص والأيقونات فوق التدرّج.
  static const Color onGradient = Color(0xFFFFFFFF);

  // ── الحالات (أساسي / نص / خلفية) ──────────────────────────────────────────
  static const Color statusPreparing = Color(0xFFF5A623);
  static const Color statusPreparingFg = Color(0xFF9A5B00);
  static const Color statusPreparingBg = Color(0xFFFEF3E2);

  static const Color statusInTransit = Color(0xFF2E86DE);
  static const Color statusInTransitFg = Color(0xFF1E64B0);
  static const Color statusInTransitBg = Color(0xFFEAF3FC);

  static const Color statusDelivered = primary;
  static const Color statusDeliveredFg = primaryDeep;
  static const Color statusDeliveredBg = primarySoft;

  static const Color statusCancelled = Color(0xFFE74C3C);
  static const Color statusCancelledFg = Color(0xFFB83227);
  static const Color statusCancelledBg = Color(0xFFFDECEA);

  // ── المحايدة ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF10232D);
  static const Color textSecondary = Color(0xFF5B6B73);
  static const Color border = Color(0xFFDDE7E6);
  static const Color skeletonBase = Color(0xFFE6EEED);
  static const Color skeletonHighlight = Color(0xFFF5F9F8);

  // ── حالة الاتصال ─────────────────────────────────────────────────────────
  static const Color offlineGrey = Color(0xFF8E8E93);
  static const Color offlineBannerBg = Color(0xFFFFF3CD);
  static const Color offlineBannerFg = Color(0xFF856404);
  static const Color onlineBannerBg = primarySoft;
  static const Color onlineBannerFg = primaryDeep;
  static const Color reconnectingBannerBg = Color(0xFFEAF3FC);
  static const Color reconnectingBannerFg = Color(0xFF1E64B0);

  // ── هيدر الطلب الملغي ────────────────────────────────────────────────────
  static const Color inkHero = Color(0xFF1E2A30);
  static const Color onInkHero = Color(0xFFFFFFFF);
}

/// ألوان الوضع الغامق (التيل ثابت، والباقي معدّل للخلفية الداكنة).
abstract final class BrandColorsDark {
  static const Color primary = BrandColors.primary;
  static const Color primaryDeep = Color(0xFF5FD3B8);
  static const Color primarySoft = Color(0xFF12302A);
  static const Color onPrimary = BrandColors.onPrimary;

  static const Color secondary = Color(0xFF7FB8D6);
  static const Color secondarySoft = Color(0xFF13283A);
  static const Color onSecondary = Color(0xFF06283B);

  static const Color gradientStart = BrandColors.gradientStart;
  static const Color gradientMid = BrandColors.gradientMid;
  static const Color gradientEnd = BrandColors.gradientEnd;
  static const Color onGradient = BrandColors.onGradient;

  static const Color statusPreparing = Color(0xFFF7B548);
  static const Color statusPreparingFg = Color(0xFFF7C46E);
  static const Color statusPreparingBg = Color(0xFF3A2C12);

  static const Color statusInTransit = Color(0xFF5AA2E8);
  static const Color statusInTransitFg = Color(0xFF8CBDF0);
  static const Color statusInTransitBg = Color(0xFF15263A);

  static const Color statusDelivered = primary;
  static const Color statusDeliveredFg = primaryDeep;
  static const Color statusDeliveredBg = primarySoft;

  static const Color statusCancelled = Color(0xFFF06A5C);
  static const Color statusCancelledFg = Color(0xFFF49489);
  static const Color statusCancelledBg = Color(0xFF3A1816);

  static const Color background = Color(0xFF0B171D);
  static const Color surface = Color(0xFF13232B);
  static const Color textPrimary = Color(0xFFEAF2F1);
  static const Color textSecondary = Color(0xFF9DB0B7);
  static const Color border = Color(0xFF223640);
  static const Color skeletonBase = Color(0xFF1B2C35);
  static const Color skeletonHighlight = Color(0xFF253A44);

  static const Color offlineGrey = Color(0xFF8E8E93);
  static const Color offlineBannerBg = Color(0xFF3A3115);
  static const Color offlineBannerFg = Color(0xFFF3D98B);
  static const Color onlineBannerBg = primarySoft;
  static const Color onlineBannerFg = primaryDeep;
  static const Color reconnectingBannerBg = Color(0xFF15263A);
  static const Color reconnectingBannerFg = Color(0xFF8CBDF0);

  static const Color inkHero = Color(0xFF1A2830);
  static const Color onInkHero = Color(0xFFEAF2F1);
}

/// الخطوط والأحجام.
abstract final class BrandTypography {
  static const String fontFamily = 'IBMPlexSansArabic';

  static const double h1 = 24;
  static const double h2 = 20;
  static const double h3 = 18;
  static const double bodyL = 16;
  static const double bodyM = 14;
  static const double caption = 12;

  /// أرقام الوقت المتوقع الكبيرة.
  static const double display = 40;

  /// عنوان الهيدر.
  static const double heroTitle = 28;

  // ارتفاع السطر أكبر للعربي حتى لا تتداخل التشكيلات.
  static const double lineHeightBody = 1.55;
  static const double lineHeightHeading = 1.4;

  static const int regular = 400;
  static const int medium = 500;
  static const int semiBold = 600;
  static const int bold = 700;
}

/// المسافات (شبكة 4).
abstract final class BrandSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const double screenGutter = md; // هامش الشاشة
  static const double cardGap = sm; // بين الكروت
  static const double minTapTarget = 48; // أصغر مساحة لمس
}

/// انحناء الزوايا.
abstract final class BrandRadius {
  static const double sm = 8;
  static const double md = 12; // الأزرار
  static const double lg = 16; // الكروت
  static const double xl = 24; // كرت الطلب الجاري
  static const double hero = 32; // أسفل الهيدر
  static const double pill = 999; // دائري كامل
}

/// «المسار»: مقاسات خط التوصيل في التقدّم والخريطة.
abstract final class BrandRoute {
  static const double stroke = 3;
  static const double dotRadius = 1.6;
  static const double dotPitch = 7;
  static const double nodeRadius = 5;
  static const double destinationRadius = 6.5;
  static const double haloRadius = 11;
}

/// الظلال.
abstract final class BrandElevation {
  static const double card = 1;
  static const double raised = 2;
  static const double shadowBlur = 12;
  static const double shadowOffsetY = 2;
  static const double shadowOpacity = 0.06; // للفاتح فقط
}

/// الحركة والأنيميشن.
abstract final class BrandMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 450);
  static const Curve curve = Curves.easeOutCubic;

  /// تأخير ظهور عناصر القائمة واحدًا تلو الآخر.
  static const Duration stagger = Duration(milliseconds: 45);
  static const int staggerMaxItems = 8;

  /// نبض المرحلة الحالية.
  static const Duration pulse = Duration(milliseconds: 1600);
}

/// أحجام الأيقونات.
abstract final class BrandIconography {
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double illustration = 120;
}

/// مسارات الشعار والرسومات.
abstract final class BrandAssets {
  static const String logomark = 'assets/brand/wasal_mark.svg';
  static const String logomarkMono = 'assets/brand/wasal_mark_mono.svg';
  static const String illustrationEmpty =
      'assets/illustrations/empty_orders.svg';
  static const String illustrationError = 'assets/illustrations/error.svg';
  static const String illustrationOffline = 'assets/illustrations/offline.svg';
}

/// قواعد استخدام الشعار.
abstract final class BrandLogoRules {
  static const double clearSpaceRatio = 0.25; // الفراغ حول الشعار
  static const double minMarkSize = 20; // أصغر حجم للرمز
  static const double minHorizontalLogoHeight = 24; // أصغر ارتفاع للشعار الأفقي
}
