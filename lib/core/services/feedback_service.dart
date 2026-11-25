import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';

enum FeedbackTone { info, warning, success }

/// رسائل سريعة (SnackBar) واهتزاز خفيف.
class FeedbackService extends GetxService {
  static const _duration = Duration(seconds: 3);

  void show(String message, {FeedbackTone tone = FeedbackTone.info}) {
    final context = Get.context;
    if (context == null) return;
    final palette = AppPalette.of(context);
    final (bg, fg, icon) = switch (tone) {
      FeedbackTone.warning => (
        palette.offlineBannerBg,
        palette.offlineBannerFg,
        Icons.wifi_off_rounded,
      ),
      FeedbackTone.success => (
        palette.statusDeliveredBg,
        palette.statusDeliveredFg,
        Icons.check_circle_outline_rounded,
      ),
      FeedbackTone.info => (
        palette.textPrimary,
        palette.surface,
        Icons.info_outline_rounded,
      ),
    };
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.showSnackbar(_build(message, bg, fg, icon));
  }

  void hapticSuccess() => HapticFeedback.lightImpact();

  void hapticSelection() => HapticFeedback.selectionClick();

  GetSnackBar _build(String message, Color bg, Color fg, IconData icon) {
    return GetSnackBar(
      messageText: Text(
        message,
        style: TextStyle(
          color: fg,
          fontSize: BrandTypography.bodyM,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: Icon(icon, color: fg, size: BrandIconography.md),
      backgroundColor: bg,
      borderRadius: BrandRadius.md,
      margin: const EdgeInsets.all(BrandSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: BrandSpacing.md,
        vertical: BrandSpacing.sm,
      ),
      snackPosition: SnackPosition.BOTTOM,
      duration: _duration,
      animationDuration: BrandMotion.base,
      forwardAnimationCurve: BrandMotion.curve,
      isDismissible: true,
    );
  }
}
