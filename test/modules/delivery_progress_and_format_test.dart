import 'package:evancode_task/core/utils/formatters.dart';
import 'package:evancode_task/data/models/order_model.dart';
import 'package:evancode_task/data/models/timeline_stage_model.dart';
import 'package:evancode_task/modules/order_detail/controllers/delivery_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(setUpArabic);

  final now = DateTime(2026, 11, 25, 14, 0);

  group('DeliveryProgress', () {
    test('in-transit: last reached stage is active with an ETA range', () {
      final order = sampleOrder(eta: now.add(const Duration(minutes: 17)));
      final steps = DeliveryProgress.stepsFor(order, now: now);
      // استلام ✓ · تجهيز ✓ · في الطريق (الآن) · تم التوصيل.
      // مرحلة «تم الاستلام من المطعم» تُتجاهل.
      expect(steps.map((s) => s.state), [
        StepState.completed,
        StepState.completed,
        StepState.active,
        StepState.upcoming,
      ]);
      expect(steps[2].note, 'متوقع الوصول خلال 15–20 دقيقة');
    });

    test('delivered: every stage completed, no active step', () {
      final order = sampleOrder(status: OrderStatus.delivered);
      final steps = DeliveryProgress.stepsFor(order, now: now);
      expect(steps.every((s) => s.state == StepState.completed), isTrue);
    });

    test('cancelled: reached stages, then a red end-cap with the reason', () {
      final at = DateTime(2026, 11, 22, 19, 5);
      final order = sampleOrder(
        status: OrderStatus.cancelled,
        cancellationReason: 'نفد الصنف',
        timeline: [
          TimelineStageModel(
            stage: DeliveryStage.received,
            labelAr: '',
            timestamp: at,
            isCompleted: true,
          ),
          TimelineStageModel(
            stage: DeliveryStage.cancelled,
            labelAr: '',
            timestamp: at.add(const Duration(minutes: 2)),
            isCompleted: true,
          ),
        ],
      );
      final steps = DeliveryProgress.stepsFor(order, now: now);
      expect(steps.map((s) => s.state), [
        StepState.completed,
        StepState.cancelled,
      ]);
      expect(steps.last.note, 'نفد الصنف');
    });

    test('ETA wording for late and imminent arrivals', () {
      expect(
        DeliveryProgress.etaText(now.subtract(const Duration(minutes: 3)), now),
        'تأخّر قليلًا — المندوب في طريقه إليك',
      );
      expect(
        DeliveryProgress.etaText(now.add(const Duration(minutes: 2)), now),
        'سيصلك خلال دقائق',
      );
    });
  });

  group('AppFormatters', () {
    test('friendly dates use Latin digits and Arabic words', () {
      expect(
        AppFormatters.friendlyDate(DateTime(2026, 11, 25, 14, 30), now: now),
        'اليوم، 2:30 م',
      );
      expect(
        AppFormatters.friendlyDate(DateTime(2026, 11, 24, 9, 15), now: now),
        'أمس، 9:15 ص',
      );
      expect(
        AppFormatters.friendlyDate(DateTime(2025, 3, 12, 21), now: now),
        '12 مارس 2025',
      );
    });

    test('relative time follows Arabic counting rules', () {
      String ago(Duration d) =>
          AppFormatters.relative(now.subtract(d), now: now);
      expect(ago(const Duration(seconds: 20)), 'الآن');
      expect(ago(const Duration(minutes: 1)), 'منذ دقيقة');
      expect(ago(const Duration(minutes: 2)), 'منذ دقيقتين');
      expect(ago(const Duration(minutes: 5)), 'منذ 5 دقائق');
      expect(ago(const Duration(minutes: 25)), 'منذ 25 دقيقة');
      expect(ago(const Duration(hours: 2)), 'منذ ساعتين');
      expect(ago(const Duration(days: 3)), 'منذ 3 أيام');
    });

    test('money is formatted with Latin digits and ر.ي', () {
      expect(AppFormatters.money(1234.5), '1,234.50 ر.ي');
    });
  });
}
