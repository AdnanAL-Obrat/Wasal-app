import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'feedback_service.dart';

/// فتح الاتصال الهاتفي.
class PhoneLauncher extends GetxService {
  PhoneLauncher(this._feedback);

  final FeedbackService _feedback;

  Future<void> dial(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    _feedback.hapticSelection();
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await launchUrl(uri)) return;
    } on PlatformException catch (e) {
      debugPrint('[PhoneLauncher] dial failed: $e');
    }
    _feedback.show('snack_call_failed'.tr);
  }
}
