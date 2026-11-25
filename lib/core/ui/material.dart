// مدخل واحد لـ Material في كل التطبيق.
// GetX ما زال يعتمد flutter/material، فالتحذير مكتوم هنا فقط.

// ignore: deprecated_member_use
export 'package:flutter/material.dart';

import 'package:flutter/widgets.dart' show LocalizationsDelegate;
import 'package:flutter_localizations/flutter_localizations.dart';

/// مترجمات الواجهة.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  // ignore: deprecated_member_use
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  // ignore: deprecated_member_use
  GlobalCupertinoLocalizations.delegate,
];
