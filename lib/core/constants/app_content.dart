abstract final class AppContent {
  /// اسم الشاشة/المنتج داخل التطبيق.
  static const String appName = 'وين طلبي؟';

  /// اسم العلامة (يظهر في الشعار وداخل الجمل مثل «تطبيق وصّل»)،
  static const String brandName = 'وصّل';

  /// الاسم الانجليزي المصغّر تحت الشعار.
  static const String brandNameLatin = 'Wasal';

  /// رقم الدعم الافتراضي — يُستخدم إذا لم يحمل الطلب رقم دعم خاصًا به.
  static const String supportPhone = '+967774744855';

  /// العملة الافتراضية إذا لم يحدد الطلب عملته.
  static const String defaultCurrency = 'YR';

  /// أضف عملة جديدة بسطر واحد؛ العملة غير المعروفة تظهر برمزها الدولي.
  static const Map<String, String> currencySymbols = {
    'SAR': 'ر.س',
    'AED': 'د.إ',
    'KWD': 'د.ك',
    'QAR': 'ر.ق',
    'BHD': 'د.ب',
    'OMR': 'ر.ع',
    'YR': 'ر.ي',
  };

  /// شكل المبلغ: فواصل الآلاف وعدد الخانات العشرية.
  static const String moneyPattern = '#,##0.00';

  /// الرمز الذي يسبق رقم الطلب («#WSL-2026-1057»).
  static const String orderNumberPrefix = '#';

  // ── روابط ────────────────────────────────────────────────────────────────
  static const String orderNowUrl = String.fromEnvironment('ORDER_NOW_URL');

  // ── البيانات التجريبية ───────────────────────────────────────────────────
  /// ملف الطلبات الذي يمثّل الخادم في هذا الإصدار.
  static const String ordersDataAsset = 'assets/data/orders.json';

  // ── مساعدات (لا تحتاج تعديلًا) ───────────────────────────────────────────
  static String currencySymbol(String code) => currencySymbols[code] ?? code;

  static Uri? get orderNowUri =>
      orderNowUrl.isEmpty ? null : Uri.tryParse(orderNowUrl);

  static String orderNumber(String id) => '$orderNumberPrefix$id';
}
