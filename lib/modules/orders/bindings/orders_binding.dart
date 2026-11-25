import 'package:get/get.dart';

import '../controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => OrdersController(
        repository: Get.find(),
        connectivity: Get.find(),
        feedback: Get.find(),
        phone: Get.find(),
      ),
    );
  }
}
