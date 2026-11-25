import 'package:get/get.dart';

import '../../core/constants/app_content.dart';

/// كل نصوص الواجهة (العربية فقط حاليًا).
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => const {'ar': _ar};
}

const Map<String, String> _ar = {
  // ── التطبيق ────────────────────────────────────────────────────────────────
  // الأسماء تُعدَّل من AppContent.
  'app_name': AppContent.appName,
  'brand_name': AppContent.brandName,
  'brand_name_latin': AppContent.brandNameLatin,

  // ── قائمة الطلبات ──────────────────────────────────────────────────────────
  'orders_title': 'طلباتي',
  'refresh': 'تحديث',
  'theme_to_dark': 'التبديل إلى الوضع الداكن',
  'theme_to_light': 'التبديل إلى الوضع الفاتح',
  'loading_orders': 'جاري تحميل طلباتك…',
  'order_card_semantics': 'طلب رقم @id، @status، المبلغ @total',
  'orders_count': '@count طلبات',
  'hero_greeting': 'أهلًا بك',
  'hero_summary_empty': 'هنا تتابع كل طلب من المطعم حتى بابك',
  'hero_summary_none': 'كل طلباتك وصلت بسلام',
  'hero_summary_one': 'لديك طلب جارٍ الآن',
  'live_order': 'طلبك الجاري',
  'section_past': 'السابقة',
  'minutes': 'دقيقة',
  'eta_label': 'الوصول المتوقع',
  'route_from': 'المطعم',
  'route_to': 'أنت',
  'courier_is': 'مندوبك',
  'call_courier': 'اتصل بالمندوب',
  'awaiting_courier': 'سنعيّن مندوبًا فور جاهزية طلبك',
  'eta_soon_short': 'دقائق',
  'eta_late_short': 'قريبًا',

  // ── شريط الاتصال ───────────────────────────────────────────────────────────
  'online_status': 'متصل — آخر تحديث: @time',
  'offline_title': 'أنت غير متصل',
  'offline_subtitle': 'تُعرض آخر قائمة محفوظة — آخر تحديث: @time',
  'offline_subtitle_no_time': 'تُعرض آخر قائمة محفوظة',
  'reconnecting': 'عاد الاتصال — جارِ التحديث…',
  'debug_offline_on': 'وضع المحاكاة: غير متصل',
  'debug_offline_off': 'وضع المحاكاة: متصل',

  // ── الحالات الفارغة والأخطاء ───────────────────────────────────────────────
  'error_title': 'تعذّر تحميل طلباتك',
  'error_subtitle': 'تأكد من اتصالك وحاول مجددًا',
  'error_offline_title': 'لا يوجد اتصال ولا بيانات محفوظة',
  'error_offline_subtitle': 'اتصل بالإنترنت مرة واحدة على الأقل لنحفظ طلباتك وتصل إليها لاحقًا دون اتصال',
  'error_parsing': 'وصلتنا بيانات غير مفهومة من الخادم، نعمل على إصلاحها',
  'error_server': 'الخادم لا يستجيب حاليًا، حاول بعد قليل',
  'retry': 'إعادة المحاولة',
  'empty_title': 'لا توجد طلبات بعد',
  'empty_subtitle':
      'عندما تطلب من «${AppContent.brandName}» ستظهر طلباتك هنا لتتابعها خطوة بخطوة',
  'order_now': 'اطلب الآن',

  // ── الإشعارات ──────────────────────────────────────────────────────────────
  'snack_offline_refresh': 'أنت غير متصل — يتم عرض آخر بيانات محفوظة',
  'snack_refresh_failed': 'تعذّر التحديث — تحقق من اتصالك',
  'snack_refreshed': 'تم تحديث طلباتك',
  'snack_order_id_copied': 'تم نسخ رقم الطلب',
  'snack_address_copied': 'تم نسخ العنوان',
  'snack_call_failed': 'تعذّر فتح تطبيق الاتصال على هذا الجهاز',
  'snack_order_now_unavailable':
      'الطلب متاح من تطبيق «${AppContent.brandName}» الرئيسي',

  // ── حالة الطلب ─────────────────────────────────────────────────────────────
  'status_preparing': 'قيد التجهيز',
  'status_in_transit': 'في الطريق',
  'status_delivered': 'تم التوصيل',
  'status_cancelled': 'ملغي',

  // ── تفاصيل الطلب ───────────────────────────────────────────────────────────
  'order_detail_title': 'تفاصيل الطلب',
  'hero_preparing': 'نجهّز طلبك الآن',
  'hero_in_transit': 'طلبك في الطريق إليك',
  'hero_delivered': 'وصل طلبك، بالعافية',
  'hero_cancelled': 'أُلغي هذا الطلب',
  'hero_unknown': 'حالة الطلب',
  'delivered_at': 'تم التسليم الساعة @time',
  'cancelled_at': 'أُلغي الساعة @time',
  'receipt': 'الفاتورة',
  'order_number': 'رقم الطلب',
  'tap_to_copy': 'اضغط للنسخ',
  'from_store': 'من @store',
  'total_amount': 'الإجمالي',
  'delivery_stages': 'مراحل التوصيل',
  'items': 'الأصناف',
  'quantity_x': '× @qty',
  'subtotal': 'المجموع الفرعي',
  'delivery_fee': 'رسوم التوصيل',
  'grand_total': 'الإجمالي النهائي',
  'delivery_address': 'عنوان التوصيل',
  'copy_address': 'نسخ العنوان',
  'courier': 'المندوب',
  'contact_courier': 'تواصل مع المندوب',
  'contact_support': 'اتصل بالدعم',
  'cancellation_reason': 'سبب الإلغاء',
  'order_not_found_title': 'لم نعثر على هذا الطلب',
  'order_not_found_subtitle': 'ارجع إلى قائمة طلباتك وحدّثها ثم حاول مجددًا',
  'back_to_orders': 'العودة إلى طلباتي',
  'detail_stale_note': 'هذه آخر حالة محفوظة — آخر تحديث: @time',
  'no_items_saved': 'تفاصيل الأصناف غير محفوظة لهذا الطلب',

  // ── مراحل التوصيل ──────────────────────────────────────────────────────────
  'stage_received': 'تم استلام الطلب',
  'stage_preparing': 'قيد التجهيز',
  'stage_in_transit': 'في الطريق إليك',
  'stage_delivered': 'تم التوصيل',
  'stage_cancelled': 'تم إلغاء الطلب',
  'stage_current': 'المرحلة الحالية',
  'eta_range': 'متوقع الوصول خلال @from–@to دقيقة',
  'eta_soon': 'سيصلك خلال دقائق',
  'eta_late': 'تأخّر قليلًا — المندوب في طريقه إليك',

  // ── التواريخ والأوقات ──────────────────────────────────────────────────────
  'today_at': 'اليوم، @time',
  'yesterday_at': 'أمس، @time',
  'just_now': 'الآن',
  'ago_minute_1': 'منذ دقيقة',
  'ago_minute_2': 'منذ دقيقتين',
  'ago_minute_few': 'منذ @n دقائق',
  'ago_minute_many': 'منذ @n دقيقة',
  'ago_hour_1': 'منذ ساعة',
  'ago_hour_2': 'منذ ساعتين',
  'ago_hour_few': 'منذ @n ساعات',
  'ago_hour_many': 'منذ @n ساعة',
  'ago_day_1': 'منذ يوم',
  'ago_day_2': 'منذ يومين',
  'ago_day_few': 'منذ @n أيام',
  'ago_day_many': 'منذ @n يومًا',
};
