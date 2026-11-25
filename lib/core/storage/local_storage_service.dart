import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_exceptions.dart';

/// غلاف بسيط للتخزين المحلي (shared_preferences).
class LocalStorageService extends GetxService {
  LocalStorageService({SharedPreferencesAsync? prefs}) : _injected = prefs;

  final SharedPreferencesAsync? _injected;

  // يُنشأ عند أول استخدام.
  late final SharedPreferencesAsync _prefs =
      _injected ?? SharedPreferencesAsync();

  Future<String?> readString(String key) async {
    try {
      return await _prefs.getString(key);
    } on Exception catch (e) {
      debugPrint('[Storage] read "$key" failed: $e');
      throw CacheException('Failed to read "$key"', e);
    }
  }

  Future<void> writeString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } on Exception catch (e) {
      debugPrint('[Storage] write "$key" failed: $e');
      throw CacheException('Failed to write "$key"', e);
    }
  }

  Future<void> remove(String key) => _prefs.remove(key);
}
