import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_content.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/ui_error.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/services/feedback_service.dart';
import '../../../core/services/phone_launcher.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';

enum ConnectionBannerState { hidden, online, offline, reconnecting }

/// متحكم الطلبات: يعرض المحفوظ فورًا ثم يحدّث في الخلفية.
class OrdersController extends GetxController {
  OrdersController({
    required this._repository,
    required this._connectivity,
    required this._feedback,
    required this._phone,
  });

  final OrderRepository _repository;
  final ConnectivityService _connectivity;
  final FeedbackService _feedback;
  final PhoneLauncher _phone;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final error = Rxn<UiError>();
  final isOffline = false.obs;
  final isReconnecting = false.obs;
  final lastUpdated = Rxn<DateTime>();

  /// تحديث كل دقيقة لأوقات «منذ X».
  final now = DateTime.now().obs;

  Timer? _ticker;
  Future<OrdersResult?>? _inFlight;

  bool get hasData => orders.isNotEmpty;

  /// الطلب الجاري الوحيد (أحدث طلب غير مكتمل).
  OrderModel? get spotlight =>
      orders.firstWhereOrNull((o) => !o.status.isFinal);

  /// باقي الطلبات بكل حالاتها.
  List<OrderModel> get pastOrders {
    final current = spotlight;
    return orders.where((o) => o != current).toList(growable: false);
  }

  /// ملخص الهيدر.
  String get heroSummary {
    if (!hasData) return 'hero_summary_empty'.tr;
    return spotlight == null ? 'hero_summary_none'.tr : 'hero_summary_one'.tr;
  }

  ConnectionBannerState get bannerState {
    if (isReconnecting.value) return ConnectionBannerState.reconnecting;
    // بدون بيانات تكفي رسالة الخطأ.
    if (!hasData) return ConnectionBannerState.hidden;
    return isOffline.value
        ? ConnectionBannerState.offline
        : ConnectionBannerState.online;
  }

  String? get lastUpdatedLabel {
    final time = lastUpdated.value;
    return time == null ? null : AppFormatters.relative(time, now: now.value);
  }

  @override
  void onInit() {
    super.onInit();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) => _tick());
    ever<bool>(_connectivity.isOnline, _onConnectivityChanged);
    loadInitial();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  Future<void> loadInitial() async {
    error.value = null;
    final cached = await _repository.readCache();
    if (cached != null) {
      _apply(cached);
    } else {
      isLoading.value = true;
    }
    await _revalidate();
  }

  /// سحب للتحديث وزر التحديث.
  Future<void> refreshOrders() async {
    if (!await _connectivity.checkNow()) {
      isOffline.value = true;
      if (!hasData) error.value = UiError.from(const OfflineException());
      _feedback.show('snack_offline_refresh'.tr, tone: FeedbackTone.warning);
      return;
    }
    if (!hasData) isLoading.value = true;
    final result = await _revalidate();
    if (result?.refreshError != null) {
      _feedback.show('snack_refresh_failed'.tr, tone: FeedbackTone.warning);
    } else if (result != null) {
      _feedback.hapticSuccess();
    }
  }

  Future<void> retry() {
    error.value = null;
    return loadInitial();
  }

  void openOrder(OrderModel order) {
    _feedback.hapticSelection();
    Get.toNamed(Routes.orderDetail, arguments: order);
  }

  Future<void> callCourier(OrderModel order) => _phone.dial(order.courierPhone);

  /// فتح رابط الطلب إن وُجد، وإلا رسالة توضيح.
  Future<void> orderNow() async {
    final uri = AppContent.orderNowUri;
    if (uri != null && await launchUrl(uri)) return;
    _feedback.show('snack_order_now_unavailable'.tr);
  }

  void toggleSimulatedOffline() {
    _connectivity.toggleSimulatedOffline();
    final key = _connectivity.simulateOffline.value
        ? 'debug_offline_on'
        : 'debug_offline_off';
    _feedback.show(key.tr);
  }

  /// دمج التحديثات المتزامنة في طلب واحد.
  Future<OrdersResult?> _revalidate() =>
      _inFlight ??= _doRevalidate().whenComplete(() => _inFlight = null);

  Future<OrdersResult?> _doRevalidate() async {
    isRefreshing.value = true;
    try {
      final result = await _repository.getOrders(forceRefresh: true);
      _apply(result);
      isOffline.value = result.refreshError != null;
      return result;
    } on AppException catch (e) {
      debugPrint('[OrdersController] no data available: $e');
      isOffline.value = e is OfflineException;
      if (!hasData) error.value = UiError.from(e);
      return null;
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isReconnecting.value = false;
    }
  }

  void _apply(OrdersResult result) {
    orders.assignAll(result.orders);
    lastUpdated.value = result.updatedAt;
    error.value = null;
  }

  void _onConnectivityChanged(bool online) {
    if (!online) {
      isOffline.value = true;
      return;
    }
    if (!isOffline.value) return;
    // عاد الاتصال: تحديث تلقائي.
    isReconnecting.value = true;
    if (!hasData) error.value = null;
    if (!hasData) isLoading.value = true;
    _revalidate();
  }

  void _tick() => now.value = DateTime.now();
}
