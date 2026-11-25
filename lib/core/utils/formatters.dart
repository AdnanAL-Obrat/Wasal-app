import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/app_content.dart';

/// تنسيق التواريخ والمبالغ بالعربي مع أرقام لاتينية.
abstract final class AppFormatters {
  static const _locale = 'ar';

  static final _time = DateFormat('h:mm a', _locale);
  static final _weekday = DateFormat('EEEE', _locale);
  static final _dayMonth = DateFormat('d MMMM', _locale);
  static final _dayMonthYear = DateFormat('d MMMM y', _locale);
  static final _fullDateTime = DateFormat('EEEE d MMMM y', _locale);
  static final _money = NumberFormat(AppContent.moneyPattern, 'en_US');

  /// تاريخ قصير: «اليوم، 2:30 م» / «أمس» / «12 مارس».
  static String friendlyDate(DateTime date, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final days = today.difference(_dateOnly(date)).inDays;
    final time = timeOf(date);
    if (days == 0) return 'today_at'.trParams({'time': time});
    if (days == 1) return 'yesterday_at'.trParams({'time': time});
    if (days > 1 && days < 7) return '${_latin(_weekday.format(date))}، $time';
    final format = date.year == today.year ? _dayMonth : _dayMonthYear;
    return _latin(format.format(date));
  }

  /// تاريخ كامل لصفحة التفاصيل.
  static String fullDateTime(DateTime date) =>
      '${_latin(_fullDateTime.format(date))} • ${timeOf(date)}';

  static String timeOf(DateTime date) => _latin(_time.format(date));

  /// المبلغ مع رمز العملة: «87.00 ر.س».
  static String money(double amount, {String? currency}) {
    final code = currency ?? AppContent.defaultCurrency;
    return '${_money.format(amount)} ${AppContent.currencySymbol(code)}';
  }

  /// الوقت النسبي: «الآن» / «منذ 5 دقائق».
  static String relative(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inMinutes < 1) return 'just_now'.tr;
    if (diff.inHours < 1) return _plural('minute', diff.inMinutes);
    if (diff.inDays < 1) return _plural('hour', diff.inHours);
    if (diff.inDays < 7) return _plural('day', diff.inDays);
    return friendlyDate(time, now: now);
  }

  /// قواعد العدد في العربية (مفرد، مثنى، جمع).
  static String _plural(String unit, int n) {
    final form = switch (n) {
      1 => '1',
      2 => '2',
      >= 3 && <= 10 => 'few',
      _ => 'many',
    };
    return 'ago_${unit}_$form'.trParams({'n': '$n'});
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static const _arabicIndic = '٠١٢٣٤٥٦٧٨٩';

  /// تحويل الأرقام العربية الهندية إلى لاتينية.
  static String _latin(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final index = _arabicIndic.indexOf(char);
      buffer.write(index == -1 ? char : '$index');
    }
    return buffer.toString();
  }
}
