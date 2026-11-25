import 'package:get/get.dart';

import '../../core/network/connectivity_service.dart';
import '../../core/services/feedback_service.dart';
import '../../core/services/phone_launcher.dart';
import '../../core/storage/local_storage_service.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/sources/order_local_source.dart';
import '../../data/sources/order_remote_source.dart';

/// اعتماديات التطبيق: الخدمات دائمة، وطبقة البيانات تُنشأ عند أول استخدام.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityService(), permanent: true);
    Get.put(LocalStorageService(), permanent: true);
    Get.put(FeedbackService(), permanent: true);
    Get.put(PhoneLauncher(Get.find()), permanent: true);

    Get.lazyPut<OrderRemoteSource>(
      () => AssetOrderRemoteSource(connectivity: Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => OrderLocalSource(Get.find()), fenix: true);
    Get.lazyPut(
      () => OrderRepository(
        remote: Get.find(),
        local: Get.find(),
        connectivity: Get.find(),
      ),
      fenix: true,
    );
  }
}
