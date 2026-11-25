import 'package:evancode_task/core/ui/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/brand_tokens.dart';
import '../../../../core/utils/responsive.dart';

/// أزرار التواصل السفلية (المندوب يظهر عند توفره).
class ContactBar extends StatelessWidget {
  const ContactBar({
    super.key,
    required this.showCourier,
    required this.showSupport,
    required this.onCallCourier,
    required this.onCallSupport,
  });

  final bool showCourier;
  final bool showSupport;
  final VoidCallback onCallCourier;
  final VoidCallback onCallSupport;

  @override
  Widget build(BuildContext context) {
    if (!showCourier && !showSupport) return const SizedBox.shrink();
    final palette = AppPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: BorderDirectional(top: BorderSide(color: palette.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(
          horizontal: Responsive.sidePadding(context),
          vertical: BrandSpacing.sm,
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            // الشاشات الضيقة: زر الدعم أيقونة فقط.
            final compact = showCourier && showSupport && box.maxWidth < 400;
            return Row(
              children: [
                if (showCourier) Expanded(child: _courierButton()),
                if (showCourier && showSupport)
                  const SizedBox(width: BrandSpacing.sm),
                if (showSupport)
                  compact
                      ? _supportIconButton()
                      : Expanded(
                          child: _supportButton(prominent: !showCourier),
                        ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _label(String key) =>
      Text(key.tr, maxLines: 1, overflow: TextOverflow.ellipsis);

  Widget _courierButton() => FilledButton.icon(
    onPressed: onCallCourier,
    icon: const Icon(Icons.phone_in_talk_outlined),
    label: _label('contact_courier'),
  );

  Widget _supportButton({required bool prominent}) {
    const icon = Icon(Icons.support_agent_outlined);
    final label = _label('contact_support');
    return prominent
        ? FilledButton.icon(onPressed: onCallSupport, icon: icon, label: label)
        : OutlinedButton.icon(
            onPressed: onCallSupport,
            icon: icon,
            label: label,
          );
  }

  Widget _supportIconButton() => IconButton.outlined(
    tooltip: 'contact_support'.tr,
    onPressed: onCallSupport,
    style: IconButton.styleFrom(
      minimumSize: const Size.square(BrandSpacing.minTapTarget),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandRadius.md),
      ),
    ),
    icon: const Icon(Icons.support_agent_outlined),
  );
}
