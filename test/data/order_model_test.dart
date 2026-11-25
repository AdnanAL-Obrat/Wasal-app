import 'dart:convert';
import 'dart:io';

import 'package:evancode_task/core/errors/app_exceptions.dart';
import 'package:evancode_task/data/models/order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<Map<String, dynamic>> rawOrders;

  setUpAll(() {
    final file = File('assets/data/orders.json').readAsStringSync();
    rawOrders = (jsonDecode(file)['orders'] as List)
        .cast<Map<String, dynamic>>();
  });

  test('bundled orders.json parses and covers every status', () {
    final orders = rawOrders.map(OrderModel.fromJson).toList();
    expect(orders.length, greaterThanOrEqualTo(5));
    expect(
      orders.map((o) => o.status).toSet(),
      containsAll(<OrderStatus>[
        OrderStatus.preparing,
        OrderStatus.inTransit,
        OrderStatus.delivered,
        OrderStatus.cancelled,
      ]),
    );
    final cancelled = orders.where((o) => o.status == OrderStatus.cancelled);
    expect(cancelled.every((o) => o.cancellationReason != null), isTrue);
  });

  test('totals in orders.json are internally consistent', () {
    for (final order in rawOrders.map(OrderModel.fromJson)) {
      final itemsSum = order.items.fold<double>(0, (s, i) => s + i.subtotal);
      expect(itemsSum, closeTo(order.itemsSubtotal, 0.001), reason: order.id);
      expect(
        order.itemsSubtotal + order.effectiveDeliveryFee,
        closeTo(order.total, 0.001),
        reason: order.id,
      );
    }
  });

  test('toJson round-trips through fromJson (cache compatibility)', () {
    for (final raw in rawOrders) {
      final order = OrderModel.fromJson(raw);
      final again = OrderModel.fromJson(
        jsonDecode(jsonEncode(order.toJson())) as Map<String, dynamic>,
      );
      expect(again.toJson(), order.toJson());
    }
  });

  test(
    'unknown status is tolerated, malformed payload is a ParsingException',
    () {
      final unknown = Map<String, dynamic>.from(rawOrders.first)
        ..['status'] = 'on_hold';
      expect(OrderModel.fromJson(unknown).status, OrderStatus.unknown);

      final broken = Map<String, dynamic>.from(rawOrders.first)
        ..['total'] = 'x';
      expect(
        () => OrderModel.fromJson(broken),
        throwsA(isA<ParsingException>()),
      );
    },
  );
}
