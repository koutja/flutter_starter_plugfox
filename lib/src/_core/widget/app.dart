import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:l10n/l10n.dart';
import 'package:starter/src/_core/config.dart';
import 'package:starter/src/_core/router/router_state_mixin.dart';
import 'package:starter/src/_core/widget/app_navigator.dart';
import 'package:starter/src/authentication/widget/scope.dart';
import 'package:starter/src/check_application/widget/scope.dart';
import 'package:starter/src/initialization/dependencies.dart';
import 'package:starter/src/payment/widget/scope.dart';
import 'package:starter/src/settings/widget/scope.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({super.key});

  static final Set<Locale> supportedLocales = <Locale>{
    const Locale('en', 'US'),
    const Locale('ru', 'RU'),
    const Locale('es', 'ES'),
    const Locale('de', 'DE'),
  };

  static AppState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppState>();

  @override
  State<App> createState() => AppState();
}

class AppState extends State<App> with RouterStateMixin {
  late final GlobalKey<State<StatefulWidget>> _builderKey =
      GlobalKey(); // Disable recreate widget tree

  Locale? _locale;

  ThemeMode _themeMode = ThemeMode.light;
  // final _lightTheme = AppThemeData.light();
  // final _darkTheme = AppThemeData.dark();

  late final AppNavigator _navigator;

  late final _scopes = OverlayEntry(
    builder: (context) {
      return CheckApplicationScope(
        checkVersion:
            Config.fake ||
            kIsWeb ||
            (!kIsWeb &&
                <TargetPlatform>{
                  TargetPlatform.android,
                  TargetPlatform.iOS,
                }.contains(defaultTargetPlatform)),
        child: PaymentScope(
          child: AuthenticationScope(
            child: SettingsScope(
              child: _navigator,
            ),
          ),
        ),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    _navigator = AppNavigator.controlled(
      controller: Dependencies.of(context).navigator,
      key: const ValueKey('app-navigator'),
    ); // AppNavigator. controlled
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    _locale =
        App.supportedLocales.any(
          (l) => l.languageCode == systemLocale.languageCode,
        )
        ? systemLocale
        : _locale;
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    restorationScopeId: 'app',
    debugShowCheckedModeBanner: !Config.environment.isProduction,
    themeMode: _themeMode,
    // theme: _lightTheme,
    // darkTheme: _darkTheme,
    locale: _locale,
    localizationsDelegates: const <LocalizationsDelegate<Object?>>[
      // AppLocalization.delegate,
      // ErrorsLocalization.delegate,
      // SignUpLocalization.delegate,
      // FeatureLocalization.delegate,
      // SettingsLocalization.delegate,
      // PayLocalization.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      Localization.delegate,
    ],
    supportedLocales: App.supportedLocales,
    onGenerateTitle: (context) => Localization.of(context).title,
    builder: (context, child) => MediaQuery(
      key: _builderKey,
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: Overlay(
        clipBehavior: Clip.none,
        key: const ValueKey('app-scopes-overlay'),
        initialEntries: [
          _scopes,
          //if (const bool.fromEnvironment('DEBUG_OVERLAY'))
          //  DebugOverlayWidgetVMLayout.overlay,
          if (!Config.environment.isProduction)
            OverlayEntry(
              builder: (context) => ExcludeSemantics(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Material(
                        color: Colors.transparent,
                        type: MaterialType.transparency,
                        child: Builder(
                          builder: (context) {
                            // final locale = Localizations.localeOf(context);
                            // final ymd = DateFormat.yMMMMEEEEd(locale);
                            // final hms = DateFormat.Hms(locale);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  '${Config.environment.name} '
                                          '${defaultTargetPlatform.name} '
                                          '${kIsWeb
                                              ? kIsWasm
                                                    ? '(WASM)'
                                                    : '(JS)'
                                              : ''}'
                                      .trim()
                                      .toUpperCase(),
                                  // style: AppTextStyle.labelMedium.style
                                  //     .copyWith(
                                  //       color: Colors.black26,
                                  //       overflow: TextOverflow.ellipsis,
                                  //     ),
                                ),
                                // AppText.labelSmall(
                                //   Pubspec.version.canonical,
                                //   color: Colors.black26,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                // AppText.labelSmall(
                                //   '${ymd.format(Pubspec.timestamp)} ${hms.format(Pubspec.timestamp)}',
                                //   color: Colors.black26,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                // AppText.labelSmall(
                                //   Dependencies.of(context).apiClient.baseUrl,
                                //   color: Colors.black26,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  void setThemeMode(ThemeMode? mode) {
    if (mode == null || _themeMode == mode) {
      return;
    }
    setState(() => _themeMode = mode);
  }

  void setLocale(String? languageCode) {
    if (languageCode == null || languageCode == _locale?.languageCode) {
      return;
    }
    if (!App.supportedLocales.any((l) => languageCode == l.languageCode)) {
      return;
    }
    // delegate.load(locale)
    setState(() => _locale = Locale(languageCode));
  }
}
