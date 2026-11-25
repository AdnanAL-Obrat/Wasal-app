import 'package:evancode_task/core/ui/material.dart';

import '../constants/brand_tokens.dart';

/// صف «عنوان ... قيمة»: القيمة في الطرف وتصغر عند ضيق المساحة.
class SpreadRow extends StatelessWidget {
  const SpreadRow({
    super.key,
    required this.leading,
    required this.trailing,
    this.gap = BrandSpacing.sm,
    this.trailingMaxFraction = 0.45,
  });

  final Widget leading;
  final Widget trailing;
  final double gap;
  final double trailingMaxFraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => Row(
        children: [
          Expanded(child: leading),
          SizedBox(width: gap),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: box.maxWidth * trailingMaxFraction,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerEnd,
              child: trailing,
            ),
          ),
        ],
      ),
    );
  }
}
