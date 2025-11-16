import 'dart:io' as io;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final IntegrationTestWidgetsFlutterBinding _binding =
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

void main() {
  setUpAll(() {
    // _binding.;
    io.Directory('integration_test/screenshots').createSync(recursive: true);
  });
  group('e2e', () {
    group('Fake auth', () {
      tearDown(() async {
        // Reset the binding to its default state
        if (_binding.inTest) await _binding.setSurfaceSize(null);
      });
      testWidgets('SignUpScreenLayout', (tester) async {
        const screenSizes = <Size>[
          Size(2560, 1440), // Large Screen
          Size(768, 1024), // Tablet
          Size(430, 932), // Large phone
          Size(320, 640), // Small phone
        ];
        const locales = <Locale>[
          Locale('en', 'US'),
          Locale('ru', 'RU'),
          Locale('es', 'ES'),
        ];
        for (final size in screenSizes) {
          for (final locale in locales) {
            // Rebuild the widget after size change
            // await tester.pumpWidget(
            //   screenBuilder(
            //     () => AuthenticationScope(
            //       key: UniqueKey(),
            //       child: const SignUpScreen(),
            //     ),
            //     // init: (deps) => deps..locale = locale,
            //     locale: locale,
            //   ),
            // );

            // await tester.setSize(size);

            // Allow UI to settle after size and locale change
            // await tester.pumpTime();

            // Make screenshot with appropriate name
            // final screenshotData = await tester.takeScreenshot();
            final _ = io.File(
              'integration_test/screenshots/'
              'SignUpScreen'
              '-${[
                size.width,
                size.height,
              ].map((n) => n.toStringAsFixed(0)).join('x')}'
              '-${locale.languageCode}'
              '.png',
            );
            // screenshotFile.writeAsBytesSync(screenshotData);
            await tester.pump(const Duration(seconds: 1));
          }
        }
        // Wait a bit and close app
        await tester.pump(const Duration(seconds: 1));
      });
    });
  });
}
