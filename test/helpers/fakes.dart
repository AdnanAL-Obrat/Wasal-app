import 'package:evancode_task/app/translations/app_translations.dart';
import 'package:evancode_task/core/errors/app_exceptions.dart';
import 'package:evancode_task/core/network/connectivity_service.dart';
import 'package:evancode_task/core/storage/local_storage_service.dart';
import 'package:evancode_task/data/models/order_item_model.dart';
import 'package:evancode_task/data/models/order_model.dart';
import 'package:evancode_task/data/models/timeline_stage_model.dart';
import 'package:evancode_task/data/sources/order_remote_source.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> setUpArabic() async {
  await initializeDateFormatting('ar');
  Get.addTranslations(AppTranslations().keys);
  Get.locale = const Locale('ar');
}

/// اتصال وهمي للاختبار.
class FakeConnectivity extends ConnectivityService {
  FakeConnectivity({this.online = true});

  bool online;
  int checks = 0;

  // بدون قنوات المنصة.
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<bool> checkNow() async {
    checks++;
    isOnline.value = online;
    return online;
  }
}

class MemoryStorage extends LocalStorageService {
  final Map<String, String> data = {};

  @override
  Future<String?> readString(String key) async => data[key];

  @override
  Future<void> writeString(String key, String value) async => data[key] = value;

  @override
  Future<void> remove(String key) async => data.remove(key);
}

class FakeRemote implements OrderRemoteSource {
  FakeRemote(this.orders);

  List<OrderModel> orders;
  AppException? failWith;
  int calls = 0;

  @override
  Future<List<OrderModel>> fetchOrders() async {
    calls++;
    if (failWith != null) throw failWith!;
    return orders;
  }
}

OrderModel sampleOrder({
  String id = 'WSL-2026-0001',
  OrderStatus status = OrderStatus.inTransit,
  DateTime? date,
  List<TimelineStageModel>? timeline,
  DateTime? eta,
  String? cancellationReason,
}) {
  final at = date ?? DateTime(2026, 11, 25, 13, 20);
  return OrderModel(
    id: id,
    date: at,
    total: 87,
    currency: 'SAR',
    status: status,
    statusLabelAr: 'في الطريق',
    deliveryAddress: 'الرياض، حي الياسمين',
    supportPhone: '+966110000000',
    courierName: 'فهد',
    courierPhone: '+966500000001',
    subtotal: 78,
    deliveryFee: 9,
    estimatedDelivery: eta,
    cancellationReason: cancellationReason,
    items: const [
      OrderItemModel(name: 'برجر', quantity: 2, unitPrice: 28),
      OrderItemModel(name: 'بطاطس', quantity: 1, unitPrice: 22),
    ],
    timeline:
        timeline ??
        [
          TimelineStageModel(
            stage: DeliveryStage.received,
            labelAr: 'تم استلام الطلب',
            timestamp: at,
            isCompleted: true,
          ),
          TimelineStageModel(
            stage: DeliveryStage.preparing,
            labelAr: 'قيد التجهيز',
            timestamp: at.add(const Duration(minutes: 4)),
            isCompleted: true,
          ),
          TimelineStageModel(
            stage: DeliveryStage.pickedUp,
            labelAr: 'تم استلامه من المتجر',
            timestamp: at.add(const Duration(minutes: 28)),
            isCompleted: true,
          ),
          TimelineStageModel(
            stage: DeliveryStage.inTransit,
            labelAr: 'في الطريق إليك',
            timestamp: at.add(const Duration(minutes: 30)),
            isCompleted: true,
          ),
          const TimelineStageModel(
            stage: DeliveryStage.delivered,
            labelAr: 'تم التوصيل',
            isCompleted: false,
          ),
        ],
  );
}
