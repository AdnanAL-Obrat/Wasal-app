import 'package:evancode_task/core/ui/material.dart';

import '../../../../data/models/timeline_stage_model.dart';

/// أيقونة لكل مرحلة (للمراحل والخريطة).
abstract final class StageIcons {
  static IconData of(DeliveryStage stage) => switch (stage) {
    DeliveryStage.received => Icons.receipt_long_rounded,
    DeliveryStage.preparing => Icons.soup_kitchen_outlined,
    DeliveryStage.pickedUp => Icons.shopping_bag_outlined, // مرحلة ملغاة
    DeliveryStage.inTransit => Icons.delivery_dining_rounded,
    DeliveryStage.delivered => Icons.task_alt_rounded,
    DeliveryStage.cancelled => Icons.close_rounded,
  };
}
