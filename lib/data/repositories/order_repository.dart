import 'package:flutter/foundation.dart';

import '../../core/errors/app_exceptions.dart';
import '../../core/network/connectivity_service.dart';
import '../models/order_model.dart';
import '../sources/order_local_source.dart';
import '../sources/order_remote_source.dart';

/// نتيجة جلب الطلبات مع مصدرها ووقت تحديثها.
class OrdersResult {
  const OrdersResult({
    required this.orders,
    required this.updatedAt,
    required this.isFromCache,
    this.refreshError,
  });

  final List<OrderModel> orders;
  final DateTime updatedAt;
  final bool isFromCache;

  /// خطأ التحديث إذا عُرضت النسخة المحفوظة بدلًا منه.
  final AppException? refreshError;
}

/// المستودع: المحفوظ أولًا ثم التحديث من الشبكة.
class OrderRepository {
  OrderRepository({
    required this._remote,
    required this._local,
    required this._connectivity,
  });

  final OrderRemoteSource _remote;
  final OrderLocalSource _local;
  final ConnectivityService _connectivity;

  /// المحفوظ فقط (للعرض الفوري).
  Future<OrdersResult?> readCache() async {
    try {
      final cached = await _local.read();
      return cached == null ? null : _fromCache(cached);
    } on CacheException catch (e) {
      debugPrint('[OrderRepository] cache unreadable: $e');
      return null;
    }
  }

  /// المحفوظ أولًا، وعند الفشل يرجع للمحفوظ.
  /// يرمي خطأ فقط إذا لم توجد نسخة محفوظة.
  Future<OrdersResult> getOrders({bool forceRefresh = false}) async {
    final cached = await readCache();
    if (cached != null && !forceRefresh) return cached;

    if (!await _connectivity.checkNow()) {
      return _fallback(cached, const OfflineException());
    }
    try {
      return await _fetchAndCache();
    } on AppException catch (e) {
      debugPrint('[OrderRepository] refresh failed: $e');
      return _fallback(cached, e);
    }
  }

  Future<OrderModel?> findCachedById(String id) async {
    final cached = await readCache();
    for (final order in cached?.orders ?? const <OrderModel>[]) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<OrdersResult> _fetchAndCache() async {
    final orders = await _remote.fetchOrders();
    final now = DateTime.now();
    try {
      await _local.save(orders, now);
    } on CacheException catch (e) {
      // فشل الحفظ لا يُلغي البيانات الجديدة.
      debugPrint('[OrderRepository] cache write failed: $e');
    }
    return OrdersResult(orders: orders, updatedAt: now, isFromCache: false);
  }

  OrdersResult _fallback(OrdersResult? cached, AppException error) {
    if (cached == null) throw error;
    return OrdersResult(
      orders: cached.orders,
      updatedAt: cached.updatedAt,
      isFromCache: true,
      refreshError: error,
    );
  }

  OrdersResult _fromCache(CachedOrders cached) => OrdersResult(
    orders: cached.orders,
    updatedAt: cached.savedAt,
    isFromCache: true,
  );
}
