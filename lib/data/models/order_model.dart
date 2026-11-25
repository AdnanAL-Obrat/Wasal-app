import '../../core/constants/app_content.dart';
import '../../core/errors/app_exceptions.dart';
import 'json_readers.dart';
import 'order_item_model.dart';
import 'timeline_stage_model.dart';

enum OrderStatus {
  preparing('preparing'),
  inTransit('in_transit'),
  delivered('delivered'),
  cancelled('cancelled'),

  /// الحالة غير المعروفة تُعرض بنصها بدل الانهيار.
  unknown('unknown');

  const OrderStatus(this.key);
  final String key;

  bool get isFinal => this == delivered || this == cancelled;

  static OrderStatus fromKey(String? key) =>
      values.firstWhere((s) => s.key == key, orElse: () => unknown);
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.date,
    required this.total,
    required this.currency,
    required this.status,
    required this.statusLabelAr,
    required this.deliveryAddress,
    required this.items,
    required this.timeline,
    this.storeName,
    this.storeLogo,
    this.subtotal,
    this.deliveryFee,
    this.estimatedDelivery,
    this.supportPhone,
    this.courierName,
    this.courierPhone,
    this.cancellationReason,
  });

  final String id;
  final DateTime date;
  final double total;
  final String currency;
  final OrderStatus status;
  final String statusLabelAr;
  final String deliveryAddress;
  final List<OrderItemModel> items;
  final List<TimelineStageModel> timeline;
  final String? storeName;

  /// شعار المطعم (مسار أو رابط).
  final String? storeLogo;
  final double? subtotal;
  final double? deliveryFee;
  final DateTime? estimatedDelivery;
  final String? supportPhone;
  final String? courierName;
  final String? courierPhone;
  final String? cancellationReason;

  /// يُحسب من الأصناف إذا لم يُرسل.
  double get itemsSubtotal =>
      subtotal ?? items.fold(0, (sum, item) => sum + item.subtotal);

  double get effectiveDeliveryFee => deliveryFee ?? (total - itemsSubtotal);

  bool get hasCourierContact => (courierPhone ?? '').isNotEmpty;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderModel(
        id: json['id'] as String,
        date: readDate(json['date']),
        total: readDouble(json['total']),
        currency: json['currency'] as String? ?? AppContent.defaultCurrency,
        status: OrderStatus.fromKey(json['status'] as String?),
        statusLabelAr: json['status_label_ar'] as String? ?? '',
        deliveryAddress: json['delivery_address'] as String? ?? '',
        items: _list(json['items'], OrderItemModel.fromJson),
        timeline: _list(json['timeline'], TimelineStageModel.fromJson),
        storeName: json['store_name'] as String?,
        storeLogo: json['store_logo'] as String?,
        subtotal: (json['subtotal'] as num?)?.toDouble(),
        deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
        estimatedDelivery: readDateOrNull(json['estimated_delivery']),
        supportPhone: json['support_phone'] as String?,
        courierName: json['courier_name'] as String?,
        courierPhone: json['courier_phone'] as String?,
        cancellationReason: json['cancellation_reason'] as String?,
      );
    } on AppException {
      rethrow;
    } on TypeError catch (e) {
      throw ParsingException('Invalid order: ${json['id']}', e);
    } on FormatException catch (e) {
      throw ParsingException('Invalid date in order: ${json['id']}', e);
    }
  }

  static List<T> _list<T>(
    Object? raw,
    T Function(Map<String, dynamic>) parse,
  ) => List<T>.unmodifiable(
    (raw as List? ?? const []).cast<Map<String, dynamic>>().map(parse),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': writeDateOrNull(date),
    'total': total,
    'currency': currency,
    'status': status.key,
    'status_label_ar': statusLabelAr,
    'delivery_address': deliveryAddress,
    'items': items.map((i) => i.toJson()).toList(),
    'timeline': timeline.map((t) => t.toJson()).toList(),
    'store_name': storeName,
    'store_logo': storeLogo,
    'subtotal': subtotal,
    'delivery_fee': deliveryFee,
    'estimated_delivery': writeDateOrNull(estimatedDelivery),
    'support_phone': supportPhone,
    'courier_name': courierName,
    'courier_phone': courierPhone,
    if (cancellationReason != null) 'cancellation_reason': cancellationReason,
  };

  OrderModel copyWith({
    DateTime? date,
    DateTime? estimatedDelivery,
    List<TimelineStageModel>? timeline,
    OrderStatus? status,
  }) => OrderModel(
    id: id,
    date: date ?? this.date,
    total: total,
    currency: currency,
    status: status ?? this.status,
    statusLabelAr: statusLabelAr,
    deliveryAddress: deliveryAddress,
    items: items,
    timeline: timeline ?? this.timeline,
    storeName: storeName,
    storeLogo: storeLogo,
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    supportPhone: supportPhone,
    courierName: courierName,
    courierPhone: courierPhone,
    cancellationReason: cancellationReason,
  );

  /// إزاحة كل الأوقات (لإبقاء البيانات التجريبية حديثة).
  OrderModel shiftedBy(Duration offset) => copyWith(
    date: date.add(offset),
    estimatedDelivery: estimatedDelivery?.add(offset),
    timeline: timeline
        .map((t) => t.copyWith(timestamp: t.timestamp?.add(offset)))
        .toList(growable: false),
  );
}
