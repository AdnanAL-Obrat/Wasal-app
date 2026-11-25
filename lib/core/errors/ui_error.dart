import 'package:get/get.dart';

import 'app_exceptions.dart';

/// رسالة خطأ ودّية بالعربي للعرض.
class UiError {
  const UiError({
    required this.title,
    required this.message,
    this.isOffline = false,
  });

  final String title;
  final String message;
  final bool isOffline;

  factory UiError.from(Object error) => switch (error) {
    OfflineException() => UiError(
      title: 'error_offline_title'.tr,
      message: 'error_offline_subtitle'.tr,
      isOffline: true,
    ),
    ParsingException() => UiError(
      title: 'error_title'.tr,
      message: 'error_parsing'.tr,
    ),
    ServerException() => UiError(
      title: 'error_title'.tr,
      message: 'error_server'.tr,
    ),
    _ => UiError(title: 'error_title'.tr, message: 'error_subtitle'.tr),
  };
}
