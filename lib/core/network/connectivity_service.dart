import 'dart:async';
import 'dart:io' show InternetAddress, SocketException;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// يتحقق من وجود إنترنت فعلي (الشبكة + فحص DNS).
class ConnectivityService extends GetxService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  static const _probeHosts = ['one.one.one.one', 'google.com'];
  static const _probeTimeout = Duration(seconds: 3);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// متصل افتراضيًا حتى أول فحص.
  final RxBool isOnline = true.obs;

  /// للتطوير فقط: محاكاة انقطاع الإنترنت.
  final RxBool simulateOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
    ever<bool>(simulateOffline, (_) => checkNow());
    checkNow();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  /// فحص فوري للاتصال.
  Future<bool> checkNow() async {
    final online = await _probe(await _connectivity.checkConnectivity());
    isOnline.value = online;
    return online;
  }

  void toggleSimulatedOffline() {
    if (!kDebugMode) return;
    simulateOffline.toggle();
    debugPrint('[Connectivity] simulateOffline=${simulateOffline.value}');
  }

  Future<void> _onChanged(List<ConnectivityResult> results) async {
    isOnline.value = await _probe(results);
    debugPrint('[Connectivity] $results → online=${isOnline.value}');
  }

  Future<bool> _probe(List<ConnectivityResult> results) async {
    if (simulateOffline.value) return false;
    if (results.every((r) => r == ConnectivityResult.none)) return false;
    if (kIsWeb) return true; // غير متاح على الويب.
    return _canResolveAnyHost();
  }

  Future<bool> _canResolveAnyHost() async {
    for (final host in _probeHosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(_probeTimeout);
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException catch (e) {
        debugPrint('[Connectivity] lookup $host failed: ${e.message}');
      } on TimeoutException {
        debugPrint('[Connectivity] lookup $host timed out');
      }
    }
    return false;
  }
}
