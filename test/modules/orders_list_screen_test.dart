import 'package:evancode_task/app/theme/app_theme.dart';
import 'package:evancode_task/app/translations/app_translations.dart';
import 'package:evancode_task/core/network/connectivity_service.dart';
import 'package:evancode_task/core/services/feedback_service.dart';
import 'package:evancode_task/core/services/phone_launcher.dart';
import 'package:evancode_task/data/models/order_model.dart';
import 'package:evancode_task/core/ui/material.dart';
import 'package:evancode_task/data/repositories/order_repository.dart';
import 'package:evancode_task/data/sources/order_local_source.dart';
import 'package:evancode_task/modules/orders/controllers/orders_controller.dart';
import 'package:evancode_task/modules/orders/views/orders_list_screen.dart';
import 'package:evancode_task/modules/orders/views/widgets/order_card.dart';
import 'package:evancode_task/modules/orders/views/widgets/spotlight_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  // إعادة تحميل الترجمات لكل اختبار.
  setUp(setUpArabic);
  tearDown(Get.reset);

  Future<FakeConnectivity> pumpScreen(
    WidgetTester tester, {
    required bool online,
    required MemoryStorage storage,
  }) async {
    final connectivity = FakeConnectivity(online: online);
    Get.put<ConnectivityService>(connectivity);
    Get.put(FeedbackService());
    Get.put(PhoneLauncher(Get.find()));
    final repository = OrderRepository(
      remote: FakeRemote([
        sampleOrder(),
        sampleOrder(id: 'WSL-2026-0002', status: OrderStatus.delivered),
      ]),
      local: OrderLocalSource(storage),
      connectivity: connectivity,
    );
    Get.put(
      OrdersController(
        repository: repository,
        connectivity: connectivity,
        feedback: Get.find(),
        phone: Get.find(),
      ),
    );
    // شاشة صغيرة لكشف الفيضان.
    tester.view.physicalSize = const Size(320, 568) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: const [Locale('ar')],
        theme: AppTheme.light,
        home: const OrdersListScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    return connectivity;
  }

  testWidgets('online: renders order cards RTL on a small screen', (
    tester,
  ) async {
    await pumpScreen(tester, online: true, storage: MemoryStorage());
    // الجاري في الهيدر، والمكتمل في القائمة.
    expect(find.byType(SpotlightCard), findsOneWidget);
    // العنوان الكبير والصغير.
    expect(find.text('طلباتي'), findsNWidgets(2));
    final direction = Directionality.of(
      tester.element(find.byType(SpotlightCard)),
    );
    expect(direction, TextDirection.rtl);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(OrderCard), findsOneWidget);
    Get.delete<OrdersController>();
  });

  testWidgets('offline with cache: shows cache and the offline banner', (
    tester,
  ) async {
    final storage = MemoryStorage();
    await OrderLocalSource(storage).save([sampleOrder()], DateTime.now());
    await pumpScreen(tester, online: false, storage: storage);
    expect(find.byType(SpotlightCard), findsOneWidget);
    // الشارة والكرت.
    expect(find.text('أنت غير متصل'), findsNWidgets(2));
    Get.delete<OrdersController>();
  });

  testWidgets('offline with no cache: inline error with retry, no dialog', (
    tester,
  ) async {
    await pumpScreen(tester, online: false, storage: MemoryStorage());
    expect(find.text('لا يوجد اتصال ولا بيانات محفوظة'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    // لا توجد نسخة محفوظة.
    expect(find.text('أنت غير متصل'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    Get.delete<OrdersController>();
  });
}
