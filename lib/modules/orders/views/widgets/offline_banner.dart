import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../controllers/orders_controller.dart';

/// شارة حالة الاتصال في الهيدر.
class ConnectionPill extends StatelessWidget {
  const ConnectionPill({
    super.key,
    required this.state,
    required this.lastUpdatedLabel,
    required this.ink,
  });

  final ConnectionBannerState state;
  final String? lastUpdatedLabel;

  /// لون النص.
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final (Widget lead, String label)? content = switch (state) {
      ConnectionBannerState.reconnecting => (
        SizedBox.square(
          dimension: 10,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: ink),
        ),
        'reconnecting'.tr,
      ),
      ConnectionBannerState.online when lastUpdatedLabel != null => (
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppPalette.of(context).statusDelivered,
            shape: BoxShape.circle,
            border: Border.all(color: ink.withValues(alpha: 0.4)),
          ),
        ),
        'online_status'.trParams({'time': lastUpdatedLabel!}),
      ),
      ConnectionBannerState.offline => (
        Icon(Icons.wifi_off_rounded, size: 13, color: ink),
        'offline_title'.tr,
      ),
      _ => null,
    };
    return AnimatedSwitcher(
      duration: BrandMotion.base,
      child: content == null
          ? const SizedBox.shrink()
          : Semantics(
              key: ValueKey('${state.name}$lastUpdatedLabel'),
              liveRegion: true,
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: BrandSpacing.sm,
                  vertical: BrandSpacing.xxs + 1,
                ),
                decoration: BoxDecoration(
                  color: ink.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(BrandRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    content.$1,
                    const SizedBox(width: BrandSpacing.xs - 2),
                    Flexible(
                      child: Text(
                        content.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: BrandTypography.caption,
                          fontWeight: FontWeight.w500,
                          color: ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// كرت «غير متصل» مع وقت آخر تحديث.
class OfflineCard extends StatelessWidget {
  const OfflineCard({super.key, required this.lastUpdatedLabel});

  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final subtitle = lastUpdatedLabel == null
        ? 'offline_subtitle_no_time'.tr
        : 'offline_subtitle'.trParams({'time': lastUpdatedLabel!});
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.all(BrandSpacing.sm),
        decoration: BoxDecoration(
          color: p.offlineBannerBg,
          borderRadius: BorderRadius.circular(BrandRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: p.offlineBannerFg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(BrandRadius.md),
              ),
              child: Icon(Icons.wifi_off_rounded, color: p.offlineBannerFg),
            ),
            const SizedBox(width: BrandSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'offline_title'.tr,
                    style: TextStyle(
                      fontSize: BrandTypography.bodyM,
                      fontWeight: FontWeight.w700,
                      color: p.offlineBannerFg,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: BrandTypography.caption,
                      height: BrandTypography.lineHeightBody,
                      color: p.offlineBannerFg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
