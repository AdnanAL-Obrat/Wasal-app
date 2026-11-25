/// أخطاء التطبيق الموحّدة؛ مصادر البيانات ترمي هذه فقط.
sealed class AppException implements Exception {
  const AppException(this.debugMessage, [this.cause]);

  /// تفاصيل للمطوّر في السجل فقط.
  final String debugMessage;
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType: $debugMessage${cause == null ? '' : ' ($cause)'}';
}

/// لا يوجد اتصال بالإنترنت.
final class OfflineException extends AppException {
  const OfflineException([
    super.debugMessage = 'Device is offline',
    super.cause,
  ]);
}

/// تعذّر قراءة البيانات القادمة.
final class ParsingException extends AppException {
  const ParsingException(super.debugMessage, [super.cause]);
}

/// فشل الخادم أو انتهت المهلة.
final class ServerException extends AppException {
  const ServerException(super.debugMessage, [super.cause]);
}

/// تعذّر القراءة أو الكتابة في التخزين المحلي.
final class CacheException extends AppException {
  const CacheException(super.debugMessage, [super.cause]);
}
