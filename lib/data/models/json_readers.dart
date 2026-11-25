// دوال مساعدة لقراءة JSON.

double readDouble(Object? value) => (value as num).toDouble();

DateTime? readDateOrNull(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toLocal();

DateTime readDate(Object? value) => DateTime.parse(value as String).toLocal();

String? writeDateOrNull(DateTime? value) => value?.toUtc().toIso8601String();
