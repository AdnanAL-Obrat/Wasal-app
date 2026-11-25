// اختبار كل الشاشات على أحجام أجهزة حقيقية وخط كبير.
import 'package:evancode_task/app/theme/app_theme.dart';
import 'package:evancode_task/app/translations/app_translations.dart';
import 'package:evancode_task/core/network/connectivity_service.dart';
import 'package:evancode_task/core/services/feedback_service.dart';
import 'package:evancode_task/core/services/phone_launcher.dart';
import 'package:evancode_task/core/ui/material.dart';
import 'package:evancode_task/core/utils/responsive.dart';
import 'package:evancode_task/data/models/order_model.dart';
import 'package:evancode_task/data/repositories/order_repository.dart';
import 'package:evancode_task/data/sources/order_local_source.dart';
import 'package:evancode_task/data/sources/order_remote_source.dart';
import 'package:evancode_task/modules/order_detail/controllers/order_detail_controller.dart';
import 'package:evancode_task/modules/order_detail/views/order_detail_screen.dart';
import 'package:evancode_task/modules/orders/controllers/orders_controller.dart';
import 'package:evancode_task/modules/orders/views/orders_list_screen.dart';
import 'package:evancode_task/modules/orders/views/widgets/order_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

/// الأجهزة المختبرة.
const _devices = <(String, Size, double)>[
  ('iPhone SE 1st gen', Size(320, 568), 20),
  ('small Android', Size(360, 640), 24),
  ('iPhone 15', Size(393, 852), 59),
  ('iPhone 15 Pro Max', Size(430, 932), 59),
  ('iPad portrait', Size(768, 1024), 24),
  ('iPad landscape', Size(1024, 768), 24),
  ('desktop', Size(1440, 900), 0),
];

const _textScales = [1.0, Responsive.maxTextScale];

void main() {
  setUp(setUpArabic);
  tearDown(Get.reset);

  late List<OrderModel> orders;

  Future<FakeConnectivity> boot(
    WidgetTester tester,
    (String, Size, double) device,
    double textScale,
  ) async {
    final (_, size, top) = device;
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    tester.view.padding = FakeViewPadding(top: top * 3, bottom: 34 * 3);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final c = FakeConnectivity();
    orders = (await tester.runAsync(
      AssetOrderRemoteSource(
        connectivity: c,
        latency: Duration.zero,
      ).fetchOrders,
    ))!;
    Get.put<ConnectivityService>(c);
    Get.put(FeedbackService());
    Get.put(PhoneLauncher(Get.find()));
    return c;
  }

  Widget app(Widget home) => GetMaterialApp(
    translations: AppTranslations(),
    locale: const Locale('ar'),
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: const [Locale('ar')],
    theme: AppTheme.light,
    home: home,
  );

  /// تمرير الصفحة لبناء كل الكروت.
  Future<void> scrollThrough(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  for (final device in _devices) {
    for (final scale in _textScales) {
      final label = '${device.$1} @${scale}x text';

      testWidgets('orders list fits: $label', (tester) async {
        final c = await boot(tester, device, scale);
        Get.put(
          OrdersController(
            repository: OrderRepository(
              remote: FakeRemote(orders),
              local: OrderLocalSource(MemoryStorage()),
              connectivity: c,
            ),
            connectivity: c,
            feedback: Get.find(),
            phone: Get.find(),
          ),
        );
        await tester.pumpWidget(app(const OrdersListScreen()));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // التأكد أن العمود لا يتجاوز العرض الأقصى.
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pump(const Duration(milliseconds: 300));
        final card = tester.getSize(find.byType(OrderCard).first);
        expect(card.width, lessThanOrEqualTo(Responsive.contentMaxWidth));

        await scrollThrough(tester);
        Get.delete<OrdersController>();
      });

      for (final index in [0, 1, 4]) {
        testWidgets('order detail #$index fits: $label', (tester) async {
          final c = await boot(tester, device, scale);
          Get.put(
            OrderDetailController(
              repository: OrderRepository(
                remote: FakeRemote(orders),
                local: OrderLocalSource(MemoryStorage()),
                connectivity: c,
              ),
              connectivity: c,
              feedback: Get.find(),
              phone: Get.find(),
              arguments: orders[index],
            ),
          );
          await tester.pumpWidget(app(const OrderDetailScreen()));
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump(const Duration(milliseconds: 500));
          await scrollThrough(tester);
          Get.delete<OrderDetailController>();
        });
      }
    }
  }
}
