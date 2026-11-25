import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../core/constants/app_content.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/network/connectivity_service.dart';
import '../models/order_model.dart';

/// مصدر الطلبات من الخادم (قابل للاستبدال بـ API حقيقي).
abstract interface class OrderRemoteSource {
  Future<List<OrderModel>> fetchOrders();
}

/// خادم تجريبي من orders.json يحاكي الشبكة (تأخير وانقطاع).
class AssetOrderRemoteSource implements OrderRemoteSource {
  AssetOrderRemoteSource({
    required this._connectivity,
    AssetBundle? bundle,
    this.latency = const Duration(milliseconds: 1200),
    this.rebaseDatesToNow = true,
  }) : _bundle = bundle ?? rootBundle;

  static const _assetPath = AppContent.ordersDataAsset;
  static const _timeout = Duration(seconds: 10);

  final ConnectivityService _connectivity;
  final AssetBundle _bundle;
  final Duration latency;

  /// إزاحة الأوقات ليبدو أحدث طلب «الآن».
  final bool rebaseDatesToNow;

  @override
  Future<List<OrderModel>> fetchOrders() async {
    if (!await _connectivity.checkNow()) {
      throw const OfflineException('No internet for remote fetch');
    }
    try {
      return await _request().timeout(_timeout);
    } on TimeoutException catch (e) {
      throw ServerException('Remote fetch timed out', e);
    }
  }

  Future<List<OrderModel>> _request() async {
    await Future<void>.delayed(latency);
    final raw = await _bundle.loadString(_assetPath, cache: false);
    return _parse(raw);
  }

  List<OrderModel> _parse(String raw) {
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final orders = (json['orders'] as List)
          .cast<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
      final shifted = _rebase(orders, json['generated_at'] as String?);
      return shifted..sort((a, b) => b.date.compareTo(a.date));
    } on AppException {
      rethrow;
    } on Object catch (e) {
      debugPrint('[Remote] parse failed: $e');
      throw ParsingException('Malformed orders payload', e);
    }
  }

  List<OrderModel> _rebase(List<OrderModel> orders, String? generatedAt) {
    if (!rebaseDatesToNow || generatedAt == null) return orders;
    final offset = DateTime.now().difference(DateTime.parse(generatedAt));
    return orders.map((o) => o.shiftedBy(offset)).toList();
  }
}
