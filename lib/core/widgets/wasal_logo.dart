import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../constants/brand_tokens.dart';

/// شعار «وصّل».
/// على خلفية ملوّنة مرّر [onColor] ليظهر بلون واحد.
class WasalMark extends StatelessWidget {
  const WasalMark({super.key, this.size = 32, this.onColor});

  final double size;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final safeSize = size < BrandLogoRules.minMarkSize
        ? BrandLogoRules.minMarkSize
        : size;
    final tint = onColor;
    if (tint == null) {
      return SvgPicture.asset(
        BrandAssets.logomark,
        width: safeSize,
        height: safeSize,
      );
    }
    return SvgPicture.asset(
      BrandAssets.logomarkMono,
      width: safeSize,
      height: safeSize,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
    );
  }
}

/// الشعار الأفقي: الرمز + الاسم.
class WasalLogo extends StatelessWidget {
  const WasalLogo({
    super.key,
    this.height = 28,
    this.showLatin = false,
    this.onColor,
  });

  final double height;
  final bool showLatin;

  /// لون الشعار على الخلفيات الملوّنة.
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final ink = onColor ?? palette.textPrimary;
    return Semantics(
      label: 'brand_name'.tr,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WasalMark(size: height, onColor: onColor),
          SizedBox(width: height * 0.28),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'brand_name'.tr,
                style: TextStyle(
                  fontSize: height * 0.72,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: ink,
                ),
              ),
              if (showLatin)
                Text(
                  'brand_name_latin'.tr,
                  style: TextStyle(
                    fontSize: height * 0.3,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    height: 1,
                    color: onColor ?? palette.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
