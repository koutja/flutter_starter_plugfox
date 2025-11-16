import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:l10n/l10n.dart';
import 'package:octopus/octopus.dart';
import 'package:starter/src/_core/config.dart';
import 'package:starter/src/_core/router/router_state_mixin.dart';
import 'package:starter/src/authentication/widget/authentication_scope.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with RouterStateMixin {
  late final _builderKey = GlobalKey(); // Disable recreate widget tree

  // late final AppNavigator _navigator;

  /* @override
void initState() {
super .initState();
_navigator = AppNavigator. controlled(
controller: Dependencies.of(context). navigator,
guards: <AppNavigationState Function(BuildContext context, AppNavigationState state)>[
// Set the title of the app based on the current page
AppNavigatorTitleGuard()),
AppNavigatorAnalyticsGuard(analytics: Dependencies.of(context). analytics),
key: const ValueKey<String>(' app-navigator"),
); // AppNavigator. controlled
final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
_locale = App.supportedLocales.any((l) => l.languageCode == systemLocale.languageCode) ? systemLocale : _locale;
}*/

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Starter',
    debugShowCheckedModeBanner: !Config.environment.isProduction,

    // Router
    routerConfig: router.config,

    // Localizations
    localizationsDelegates: const <LocalizationsDelegate<Object?>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      Localization.delegate,
    ],
    supportedLocales: Localization.supportedLocales,
    /* locale: SettingsScope.localOf(context), */

    // Theme
    /* theme: SettingsScope.themeOf(context), */
    theme: ThemeData.light(),

    // Scopes
    builder: (context, child) => MediaQuery(
      key: _builderKey,
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: OctopusTools(
        octopus: router,
        child: AuthenticationScope(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    ),
  );
}
