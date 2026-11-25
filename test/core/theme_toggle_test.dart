import 'package:evancode_task/app/theme/app_theme.dart';
import 'package:evancode_task/app/translations/app_translations.dart';
import 'package:evancode_task/core/services/theme_service.dart';
import 'package:evancode_task/core/ui/material.dart';
import 'package:evancode_task/core/widgets/theme_reveal.dart';
import 'package:evancode_task/core/widgets/theme_toggle_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/fakes.dart';

void main() {
  setUp(setUpArabic);
  tearDown(Get.reset);

  testWidgets('toggle flips light → dark, animates and persists', (
    tester,
  ) async {
    final storage = MemoryStorage();
    storage.data['theme_mode_v1'] = 'light';
    final service = await ThemeService.create(storage);
    Get.put(service);
    expect(service.mode.value, ThemeMode.light);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('ar'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: const [Locale('ar')],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: service.mode.value,
        builder: (_, child) =>
            ThemeReveal(key: service.revealKey, child: child!),
        home: Scaffold(
          appBar: AppBar(
            actions: const [ThemeToggleButton(color: Colors.black)],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ThemeToggleButton));
    // انتظار انتهاء الأنيميشن.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(service.mode.value, ThemeMode.dark);
    expect(storage.data['theme_mode_v1'], 'dark');
    final context = tester.element(find.byType(ThemeToggleButton));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  test('unknown saved value falls back to following the system', () async {
    final storage = MemoryStorage()..data['theme_mode_v1'] = 'sepia';
    final service = await ThemeService.create(storage);
    expect(service.mode.value, ThemeMode.system);
  });
}
