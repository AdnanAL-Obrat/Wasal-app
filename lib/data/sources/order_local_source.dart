import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/storage/local_storage_service.dart';
import '../models/order_model.dart';

/// نسخة محفوظة من الطلبات ووقت حفظها.
class CachedOrders {
  const CachedOrders({required this.orders, required this.savedAt});

  final List<OrderModel> orders;
  final DateTime savedAt;
}

/// حفظ آخر قائمة طلبات كـ JSON.
class OrderLocalSource {
  OrderLocalSource(this._storage);

  // غيّر الرقم عند تغيّر شكل البيانات.
  static const _cacheKey = 'orders_cache_v1';

  final LocalStorageService _storage;

  Future<CachedOrders?> read() async {
    final raw = await _storage.readString(_cacheKey);
    if (raw == null) return null;
    try {
      return _decode(raw);
    } on Object catch (e) {
      // النسخة التالفة تُحذف ويُعاد الجلب.
      debugPrint('[LocalSource] corrupt cache discarded: $e');
      await _storage.remove(_cacheKey);
      return null;
    }
  }

  Future<void> save(List<OrderModel> orders, DateTime savedAt) {
    final payload = jsonEncode({
      'saved_at': savedAt.toUtc().toIso8601String(),
      'orders': orders.map((o) => o.toJson()).toList(),
    });
    return _storage.writeString(_cacheKey, payload);
  }

  CachedOrders _decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final orders = (json['orders'] as List)
        .cast<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList(growable: false);
    final savedAt = DateTime.tryParse(json['saved_at'] as String? ?? '');
    if (savedAt == null) throw const ParsingException('Missing saved_at');
    return CachedOrders(orders: orders, savedAt: savedAt.toLocal());
  }
}
