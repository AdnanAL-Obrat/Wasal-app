import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../errors/app_exceptions.dart';
import '../storage/local_storage_service.dart';
import '../widgets/theme_reveal.dart';

/// إدارة الوضع الفاتح/الغامق وحفظه.
class ThemeService extends GetxService {
  ThemeService._(this._storage, ThemeMode initial) : mode = initial.obs;

  static const _key = 'theme_mode_v1';

  final LocalStorageService _storage;
  final Rx<ThemeMode> mode;

  /// مرجع أنيميشن الدائرة في main.dart.
  final revealKey = GlobalKey<ThemeRevealState>();

  /// قراءة الوضع المحفوظ، وإلا وضع النظام.
  static Future<ThemeService> create(LocalStorageService storage) async {
    var initial = ThemeMode.system;
    try {
      final raw = await storage.readString(_key);
      initial = ThemeMode.values.firstWhere(
        (m) => m.name == raw,
        orElse: () => ThemeMode.system,
      );
    } on CacheException catch (e) {
      debugPrint('[ThemeService] could not restore theme: $e');
    }
    return ThemeService._(storage, initial);
  }

  /// تبديل الوضع بأنيميشن دائرة من مكان الزر.
  Future<void> toggle({required bool isDark, required Offset origin}) async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    HapticFeedback.selectionClick();
    void apply() {
      mode.value = next;
      Get.changeThemeMode(next);
    }

    final reveal = revealKey.currentState;
    reveal == null
        ? apply()
        : await reveal.reveal(origin: origin, apply: apply);
    try {
      await _storage.writeString(_key, next.name);
    } on CacheException catch (e) {
      debugPrint('[ThemeService] could not save theme: $e');
    }
  }
}
