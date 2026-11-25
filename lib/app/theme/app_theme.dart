import 'package:evancode_task/core/ui/material.dart';

import '../../core/constants/brand_tokens.dart';

/// ألوان الهوية الإضافية (الحالات، الاتصال، التحميل) لكل وضع.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.primaryDeep,
    required this.primarySoft,
    required this.secondary,
    required this.secondarySoft,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.statusPreparing,
    required this.statusPreparingFg,
    required this.statusPreparingBg,
    required this.statusInTransit,
    required this.statusInTransitFg,
    required this.statusInTransitBg,
    required this.statusDelivered,
    required this.statusDeliveredFg,
    required this.statusDeliveredBg,
    required this.statusCancelled,
    required this.statusCancelledFg,
    required this.statusCancelledBg,
    required this.offlineGrey,
    required this.offlineBannerBg,
    required this.offlineBannerFg,
    required this.onlineBannerBg,
    required this.onlineBannerFg,
    required this.reconnectingBannerBg,
    required this.reconnectingBannerFg,
    required this.shadow,
    required this.inkHero,
    required this.onInkHero,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.onGradient,
  });

  final Color primary, primaryDeep, primarySoft, secondary, secondarySoft;
  final Color background, surface, textPrimary, textSecondary, border;
  final Color skeletonBase, skeletonHighlight;
  final Color statusPreparing, statusPreparingFg, statusPreparingBg;
  final Color statusInTransit, statusInTransitFg, statusInTransitBg;
  final Color statusDelivered, statusDeliveredFg, statusDeliveredBg;
  final Color statusCancelled, statusCancelledFg, statusCancelledBg;
  final Color offlineGrey, offlineBannerBg, offlineBannerFg;
  final Color onlineBannerBg, onlineBannerFg;
  final Color reconnectingBannerBg, reconnectingBannerFg;
  final Color shadow;
  final Color inkHero, onInkHero;
  final Color gradientStart, gradientMid, gradientEnd, onGradient;

  /// تدرّج الهيدر: كحلي مع توهّج تيل من الزاوية السفلية.
  Gradient get headerGradient => RadialGradient(
    center: AlignmentDirectional.bottomEnd,
    radius: 1.35,
    colors: [gradientStart, gradientMid, gradientEnd],
    stops: const [0, 0.42, 1],
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  static final light = AppPalette(
    primary: BrandColors.primary,
    primaryDeep: BrandColors.primaryDeep,
    primarySoft: BrandColors.primarySoft,
    secondary: BrandColors.secondary,
    secondarySoft: BrandColors.secondarySoft,
    background: BrandColors.background,
    surface: BrandColors.surface,
    textPrimary: BrandColors.textPrimary,
    textSecondary: BrandColors.textSecondary,
    border: BrandColors.border,
    skeletonBase: BrandColors.skeletonBase,
    skeletonHighlight: BrandColors.skeletonHighlight,
    statusPreparing: BrandColors.statusPreparing,
    statusPreparingFg: BrandColors.statusPreparingFg,
    statusPreparingBg: BrandColors.statusPreparingBg,
    statusInTransit: BrandColors.statusInTransit,
    statusInTransitFg: BrandColors.statusInTransitFg,
    statusInTransitBg: BrandColors.statusInTransitBg,
    statusDelivered: BrandColors.statusDelivered,
    statusDeliveredFg: BrandColors.statusDeliveredFg,
    statusDeliveredBg: BrandColors.statusDeliveredBg,
    statusCancelled: BrandColors.statusCancelled,
    statusCancelledFg: BrandColors.statusCancelledFg,
    statusCancelledBg: BrandColors.statusCancelledBg,
    offlineGrey: BrandColors.offlineGrey,
    offlineBannerBg: BrandColors.offlineBannerBg,
    offlineBannerFg: BrandColors.offlineBannerFg,
    onlineBannerBg: BrandColors.onlineBannerBg,
    onlineBannerFg: BrandColors.onlineBannerFg,
    reconnectingBannerBg: BrandColors.reconnectingBannerBg,
    reconnectingBannerFg: BrandColors.reconnectingBannerFg,
    shadow: BrandColors.textPrimary.withValues(
      alpha: BrandElevation.shadowOpacity,
    ),
    inkHero: BrandColors.inkHero,
    onInkHero: BrandColors.onInkHero,
    gradientStart: BrandColors.gradientStart,
    gradientMid: BrandColors.gradientMid,
    gradientEnd: BrandColors.gradientEnd,
    onGradient: BrandColors.onGradient,
  );

  static const dark = AppPalette(
    primary: BrandColorsDark.primary,
    primaryDeep: BrandColorsDark.primaryDeep,
    primarySoft: BrandColorsDark.primarySoft,
    secondary: BrandColorsDark.secondary,
    secondarySoft: BrandColorsDark.secondarySoft,
    background: BrandColorsDark.background,
    surface: BrandColorsDark.surface,
    textPrimary: BrandColorsDark.textPrimary,
    textSecondary: BrandColorsDark.textSecondary,
    border: BrandColorsDark.border,
    skeletonBase: BrandColorsDark.skeletonBase,
    skeletonHighlight: BrandColorsDark.skeletonHighlight,
    statusPreparing: BrandColorsDark.statusPreparing,
    statusPreparingFg: BrandColorsDark.statusPreparingFg,
    statusPreparingBg: BrandColorsDark.statusPreparingBg,
    statusInTransit: BrandColorsDark.statusInTransit,
    statusInTransitFg: BrandColorsDark.statusInTransitFg,
    statusInTransitBg: BrandColorsDark.statusInTransitBg,
    statusDelivered: BrandColorsDark.statusDelivered,
    statusDeliveredFg: BrandColorsDark.statusDeliveredFg,
    statusDeliveredBg: BrandColorsDark.statusDeliveredBg,
    statusCancelled: BrandColorsDark.statusCancelled,
    statusCancelledFg: BrandColorsDark.statusCancelledFg,
    statusCancelledBg: BrandColorsDark.statusCancelledBg,
    offlineGrey: BrandColorsDark.offlineGrey,
    offlineBannerBg: BrandColorsDark.offlineBannerBg,
    offlineBannerFg: BrandColorsDark.offlineBannerFg,
    onlineBannerBg: BrandColorsDark.onlineBannerBg,
    onlineBannerFg: BrandColorsDark.onlineBannerFg,
    reconnectingBannerBg: BrandColorsDark.reconnectingBannerBg,
    reconnectingBannerFg: BrandColorsDark.reconnectingBannerFg,
    shadow: Color(0x00000000),
    inkHero: BrandColorsDark.inkHero,
    onInkHero: BrandColorsDark.onInkHero,
    gradientStart: BrandColorsDark.gradientStart,
    gradientMid: BrandColorsDark.gradientMid,
    gradientEnd: BrandColorsDark.gradientEnd,
    onGradient: BrandColorsDark.onGradient,
  );

  @override
  AppPalette copyWith() => this;

  // الألوان تتبدّل مباشرة مع الوضع.
  @override
  AppPalette lerp(AppPalette? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light, AppPalette.light);
  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  static ThemeData _build(Brightness brightness, AppPalette p) {
    final scheme = _scheme(brightness, p);
    final text = _textTheme(p);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: BrandTypography.fontFamily,
      scaffoldBackgroundColor: p.background,
      textTheme: text,
      extensions: [p],
      appBarTheme: _appBar(p, text),
      cardTheme: _card(p),
      filledButtonTheme: _filledButton(p),
      outlinedButtonTheme: _outlinedButton(p),
      textButtonTheme: _textButton(p),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.primarySoft,
        refreshBackgroundColor: p.surface,
      ),
      iconTheme: IconThemeData(color: p.textPrimary, size: BrandIconography.lg),
      // الانتقالات معرّفة في app_pages.dart.
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ColorScheme _scheme(Brightness brightness, AppPalette p) =>
      ColorScheme(
        brightness: brightness,
        primary: p.primary,
        onPrimary: BrandColors.onPrimary,
        primaryContainer: p.primarySoft,
        onPrimaryContainer: p.primaryDeep,
        secondary: p.secondary,
        onSecondary: brightness == Brightness.light
            ? BrandColors.onSecondary
            : BrandColorsDark.onSecondary,
        secondaryContainer: p.secondarySoft,
        onSecondaryContainer: p.secondary,
        error: p.statusCancelled,
        onError: Colors.white,
        surface: p.surface,
        onSurface: p.textPrimary,
        onSurfaceVariant: p.textSecondary,
        outline: p.border,
        outlineVariant: p.border,
        surfaceTint: Colors.transparent,
      );

  static TextStyle _style(
    double size,
    FontWeight weight,
    Color color, {
    double height = BrandTypography.lineHeightBody,
  }) => TextStyle(
    fontFamily: BrandTypography.fontFamily,
    fontSize: size,
    fontWeight: weight,
    height: height,
    color: color,
  );

  /// ربط أحجام الخط بأدوار Material.
  static TextTheme _textTheme(AppPalette p) {
    const heading = BrandTypography.lineHeightHeading;
    return TextTheme(
      headlineSmall: _style(
        BrandTypography.h1,
        FontWeight.w700,
        p.textPrimary,
        height: heading,
      ),
      titleLarge: _style(
        BrandTypography.h2,
        FontWeight.w600,
        p.textPrimary,
        height: heading,
      ),
      titleMedium: _style(
        BrandTypography.h3,
        FontWeight.w600,
        p.textPrimary,
        height: heading,
      ),
      titleSmall: _style(BrandTypography.bodyL, FontWeight.w600, p.textPrimary),
      bodyLarge: _style(BrandTypography.bodyL, FontWeight.w400, p.textPrimary),
      bodyMedium: _style(BrandTypography.bodyM, FontWeight.w400, p.textPrimary),
      bodySmall: _style(
        BrandTypography.caption,
        FontWeight.w400,
        p.textSecondary,
      ),
      labelLarge: _style(BrandTypography.bodyL, FontWeight.w600, p.textPrimary),
      labelMedium: _style(
        BrandTypography.bodyM,
        FontWeight.w500,
        p.textPrimary,
      ),
      labelSmall: _style(
        BrandTypography.caption,
        FontWeight.w500,
        p.textSecondary,
      ),
    );
  }

  static AppBarTheme _appBar(AppPalette p, TextTheme text) => AppBarTheme(
    backgroundColor: p.background,
    foregroundColor: p.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: text.titleLarge,
  );

  static CardThemeData _card(AppPalette p) => CardThemeData(
    color: p.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BrandRadius.md),
      side: BorderSide(color: p.border),
    ),
  );

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(BrandRadius.md)),
  );

  static const _buttonSize = Size(0, BrandSpacing.minTapTarget);

  static TextStyle get _buttonText => const TextStyle(
    fontFamily: BrandTypography.fontFamily,
    fontSize: BrandTypography.bodyL,
    fontWeight: FontWeight.w600,
  );

  static FilledButtonThemeData _filledButton(AppPalette p) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: BrandColors.onPrimary,
          disabledBackgroundColor: p.border,
          disabledForegroundColor: p.textSecondary,
          minimumSize: _buttonSize,
          shape: _buttonShape,
          textStyle: _buttonText,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: BrandSpacing.xl,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButton(AppPalette p) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.border),
          minimumSize: _buttonSize,
          shape: _buttonShape,
          textStyle: _buttonText,
        ),
      );

  static TextButtonThemeData _textButton(AppPalette p) => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: p.primaryDeep,
      textStyle: _buttonText.copyWith(fontSize: BrandTypography.bodyM),
    ),
  );
}
