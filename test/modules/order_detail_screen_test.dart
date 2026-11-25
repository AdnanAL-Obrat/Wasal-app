import 'package:evancode_task/app/theme/app_theme.dart';
import 'package:evancode_task/app/translations/app_translations.dart';
import 'package:evancode_task/core/network/connectivity_service.dart';
import 'package:evancode_task/core/services/feedback_service.dart';
import 'package:evancode_task/core/services/phone_launcher.dart';
import 'package:evancode_task/core/ui/material.dart';
import 'package:evancode_task/core/widgets/route_map.dart';
import 'package:evancode_task/data/models/order_model.dart';
import 'package:evancode_task/data/models/timeline_stage_model.dart';
import 'package:evancode_task/data/repositories/order_repository.dart';
import 'package:evancode_task/data/sources/order_local_source.dart';
import 'package:evancode_task/modules/order_detail/controllers/delivery_progress.dart';
import 'package:evancode_task/modules/order_detail/controllers/order_detail_controller.dart';
import 'package:evancode_task/modules/order_detail/views/order_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  setUp(setUpArabic);
  tearDown(Get.reset);

  Future<void> pumpDetail(
    WidgetTester tester,
    OrderModel order, {
    bool dark = false,
  }) async {
    final connectivity = FakeConnectivity();
    Get.put<ConnectivityService>(connectivity);
    Get.put(FeedbackService());
    Get.put(PhoneLauncher(Get.find()));
    Get.put(
      OrderDetailController(
        repository: OrderRepository(
          remote: FakeRemote([order]),
          local: OrderLocalSource(MemoryStorage()),
          connectivity: connectivity,
        ),
        connectivity: connectivity,
        feedback: Get.find(),
        phone: Get.find(),
        arguments: order,
      ),
    );
    tester.view.physicalSize = const Size(320, 568) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: const [Locale('ar')],
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: const OrderDetailScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
  }

  final now = DateTime.now();

  testWidgets('in transit: ember hero with live map and ETA numerals', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      sampleOrder(
        date: now.subtract(const Duration(minutes: 40)),
        eta: now.add(const Duration(minutes: 17)),
      ),
    );
    expect(find.text('طلبك في الطريق إليك'), findsOneWidget);
    expect(find.text('15–20'), findsOneWidget);
    expect(find.byType(RouteMap), findsOneWidget);
    expect(find.text('تواصل مع المندوب'), findsOneWidget);
    Get.delete<OrderDetailController>();
  });

  testWidgets('delivered (dark theme): headline and no courier button', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      sampleOrder(status: OrderStatus.delivered),
      dark: true,
    );
    expect(find.text('وصل طلبك، بالعافية'), findsOneWidget);
    expect(find.text('تواصل مع المندوب'), findsNothing);
    Get.delete<OrderDetailController>();
  });

  testWidgets('cancelled: reason shown after scrolling, total struck', (
    tester,
  ) async {
    final at = DateTime(2026, 11, 22, 19, 5);
    await pumpDetail(
      tester,
      sampleOrder(
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
      ),
    );
    expect(find.text('أُلغي هذا الطلب'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('نفد الصنف'), findsOneWidget);
    Get.delete<OrderDetailController>();
  });

  test('preparing stays at the restaurant with the kitchen stage', () {
    final order = sampleOrder(
      status: OrderStatus.preparing,
      timeline: [
        TimelineStageModel(
          stage: DeliveryStage.received,
          labelAr: '',
          timestamp: DateTime(2026, 11, 25, 12, 40),
          isCompleted: true,
        ),
        TimelineStageModel(
          stage: DeliveryStage.preparing,
          labelAr: '',
          timestamp: DateTime(2026, 11, 25, 12, 46),
          isCompleted: true,
        ),
      ],
    );
    expect(DeliveryProgress.currentStage(order), DeliveryStage.preparing);
    expect(DeliveryProgress.routeFraction(order, DateTime.now()), 0);
  });

  test('route fraction moves with time while in transit', () {
    final left = DateTime(2026, 11, 25, 13, 50);
    final order = sampleOrder(
      date: DateTime(2026, 11, 25, 13, 20),
      eta: left.add(const Duration(minutes: 20)),
    );
    final early = DeliveryProgress.routeFraction(order, left);
    final later = DeliveryProgress.routeFraction(
      order,
      left.add(const Duration(minutes: 15)),
    );
    expect(early, closeTo(0.12, 0.001));
    expect(later, greaterThan(early));
    expect(DeliveryProgress.reachedIndex(order), 2);
    expect(DeliveryProgress.currentStage(order), DeliveryStage.inTransit);
  });
}
