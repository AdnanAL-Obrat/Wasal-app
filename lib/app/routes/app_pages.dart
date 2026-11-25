import 'package:get/get.dart';

import '../../core/constants/brand_tokens.dart';
import '../../modules/order_detail/bindings/order_detail_binding.dart';
import '../../modules/order_detail/views/order_detail_screen.dart';
import '../../modules/orders/bindings/orders_binding.dart';
import '../../modules/orders/views/orders_list_screen.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static const initial = Routes.orders;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.orders,
      page: () => const OrdersListScreen(),
      binding: OrdersBinding(),
    ),
    // انتقال Cupertino: يدعم الاتجاه العربي وسحب الرجوع من الحافة.
    GetPage(
      name: Routes.orderDetail,
      page: () => const OrderDetailScreen(),
      binding: OrderDetailBinding(),
      transition: Transition.cupertino,
      transitionDuration: BrandMotion.base,
      curve: BrandMotion.curve,
    ),
  ];
}
