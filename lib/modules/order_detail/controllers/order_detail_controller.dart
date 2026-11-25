import 'dart:async';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_content.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/phone_launcher.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import 'delivery_progress.dart';

/// يعمل بدون إنترنت: الطلب يصل من القائمة أو من المحفوظ.
class OrderDetailController extends GetxController {
  OrderDetailController({
    required this._repository,
    required this._connectivity,
    required this._feedback,
    required this._phone,
    this._arguments,
  });

  final OrderRepository _repository;
  final ConnectivityService _connectivity;
  final FeedbackService _feedback;
  final PhoneLauncher _phone;
  final Object? _arguments;

  final order = Rxn<OrderModel>();
  final isResolving = true.obs;
  final lastSynced = Rxn<DateTime>();
  final now = DateTime.now().obs;

  Timer? _ticker;

  RxBool get isOnline => _connectivity.isOnline;

  List<TimelineStep> get steps {
    final current = order.value;
    return current == null
        ? const []
        : DeliveryProgress.stepsFor(current, now: now.value);
  }

  String? get staleNote {
    final synced = lastSynced.value;
    if (isOnline.value || synced == null) return null;
    return 'detail_stale_note'.trParams({
      'time': AppFormatters.relative(synced, now: now.value),
    });
  }

  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => now.value = DateTime.now(),
    );
    _resolveOrder();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  Future<void> copyOrderId() async {
    final current = order.value;
    if (current == null) return;
    await Clipboard.setData(ClipboardData(text: current.id));
    _feedback.hapticSuccess();
    _feedback.show('snack_order_id_copied'.tr, tone: FeedbackTone.success);
  }

  Future<void> copyAddress() async {
    final current = order.value;
    if (current == null) return;
    await Clipboard.setData(ClipboardData(text: current.deliveryAddress));
    _feedback.hapticSuccess();
    _feedback.show('snack_address_copied'.tr, tone: FeedbackTone.success);
  }

  Future<void> callCourier() => _phone.dial(order.value?.courierPhone);

  /// رقم دعم الطلب، وإلا الرقم العام.
  Future<void> callSupport() {
    final own = order.value?.supportPhone ?? '';
    return _phone.dial(own.isNotEmpty ? own : AppContent.supportPhone);
  }

  void back() => Get.back<void>();

  Future<void> _resolveOrder() async {
    final args = _arguments;
    if (args is OrderModel) {
      order.value = args;
    } else if (args is String) {
      order.value = await _repository.findCachedById(args);
    }
    isResolving.value = false;
    lastSynced.value = (await _repository.readCache())?.updatedAt;
  }
}
