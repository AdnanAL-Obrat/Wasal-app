import 'package:get/get.dart';

import '../controllers/order_detail_controller.dart';

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => OrderDetailController(
        repository: Get.find(),
        connectivity: Get.find(),
        feedback: Get.find(),
        phone: Get.find(),
        arguments: Get.arguments,
      ),
    );
  }
}
