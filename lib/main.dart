import 'package:evancode_task/core/ui/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'core/constants/app_content.dart';
import 'core/services/theme_service.dart';
import 'core/storage/local_storage_service.dart';
import 'core/utils/responsive.dart';
import 'core/widgets/theme_reveal.dart';

const _arabic = Locale('ar');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تحميل أسماء الأشهر والأيام بالعربي.
  await initializeDateFormatting('ar');
  await _lockPhonesToPortrait();
  // استرجاع الثيم المحفوظ قبل أول إطار.
  final themeService = await ThemeService.create(LocalStorageService());
  Get.put(themeService, permanent: true);
  runApp(const WaynTalabiApp());
}

/// الجوال عمودي فقط؛ التابلت يدور بحرية.
Future<void> _lockPhonesToPortrait() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortest = view.physicalSize.shortestSide / view.devicePixelRatio;
  return SystemChrome.setPreferredOrientations(
    shortest < Responsive.mediumFrom ? [DeviceOrientation.portraitUp] : [],
  );
}

class WaynTalabiApp extends StatelessWidget {
  const WaynTalabiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppContent.brandName, // اسم التطبيق في مبدّل التطبيقات
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: _arabic,
      fallbackLocale: _arabic,
      supportedLocales: const [_arabic],
      localizationsDelegates: appLocalizationsDelegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: Get.find<ThemeService>().mode.value,
      // أنيميشن الدائرة عند تبديل الثيم.
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        // دعم تكبير الخط مع حد أعلى.
        maxScaleFactor: Responsive.maxTextScale,
        child: ThemeReveal(
          key: Get.find<ThemeService>().revealKey,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
