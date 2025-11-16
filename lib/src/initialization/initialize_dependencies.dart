import 'dart:async';

import 'package:control/control.dart';
import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/src/_core/analytics.dart';
import 'package:starter/src/_core/config.dart';
import 'package:starter/src/authentication/controller/authentication_controller.dart';
import 'package:starter/src/authentication/data/authentication_repository.dart';
import 'package:starter/src/initialization/app_metadata.dart';
import 'package:starter/src/initialization/app_migrator.dart';
import 'package:starter/src/initialization/controller_observer.dart';
import 'package:starter/src/initialization/dependencies.dart';
import 'package:starter/src/initialization/platform/platform_initialization.dart'
    as platform_initialization;

/// Initializes the app and returns a [Dependencies] object
Future<Dependencies> $initializeDependencies({
  void Function(int progress, String message)? onProgress,
}) async {
  final dependencies = Dependencies();
  final totalSteps = _initializationSteps.length;
  var currentStep = 0;
  for (final step in _initializationSteps.entries) {
    try {
      currentStep++;
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.key);
      l.v6(
        'Initialization | $currentStep/$totalSteps ($percent%) | "${step.key}"',
      );
      await step.value(dependencies);
    } on Object catch (e, st) {
      l.e('Initialization failed at step "${step.key}": $e', st);
      Error.throwWithStackTrace(
        'Initialization failed at step "${step.key}": $e',
        st,
      );
    }
  }
  return dependencies;
}

typedef _InitializationStep = FutureOr<void> Function(Dependencies deps);

final Map<String, _InitializationStep>
_initializationSteps = <String, _InitializationStep>{
  'Platform pre-initialization': (_) =>
      platform_initialization.$platformInitialization(),
  'Creating app metadata': (deps) {
    deps.metadata = AppMetadata.platform();
  },
  'Log app open': (_) {},
  'Locale storage initialization': (deps) {
    deps.prefs = SharedPreferencesAsync();
  },
  'Migrate app from previous version': (deps) async {
    await AppMigrator.migrate(deps.prefs);
  },
  'Observer state management': (_) {
    Controller.observer = const GlobalControllerObserver();
  },
  'Firebase initialization': (_) async {
    // final _ = await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // await platform_initialization.$firebaseAppCheckInitialization();
  },
  'Open database': (deps) async {
    // deps.database = Database.platform(dropDatabase: Config.dropDatabase);
    // await deps.database.refresh();
    // deps.database
    //   ..setKey('app_version', Pubspec.version.canonical)
    //   ..setKey('app_last_launch', DateTime.now().millisecondsSinceEpoch);
  },
  'Initializing analytics': (deps) {
    deps.analytics = Analytics.instance;
  },
  'HTTP client': (deps) async {
    final apiBaseUrl = await _apiBaseUrlString(deps);
    Object httpFactory([Iterable<Object>? middlewares]) {
      final list = <Object>[
        apiBaseUrl,
      ];
      if (middlewares != null) {
        list.addAll(middlewares);
      }
      // TODO(koutja): create ApiClient
      // return Object(apiBaseUrl, list);
      return Object();
    }

    deps.httpFactory = httpFactory;
  },
  'Authentication repository': (deps) async {
    deps.authenticationController = AuthenticationController(
      repository: AuthenticationRepository$Fake(
        prefs: deps.prefs,
      ),
    );
  },
  'Generate Http Client': (deps) {
    deps.httpClient = deps.httpFactory([
      // TODO(koutja): Add AuthenticationMiddleware
      // AuthenticationMiddleware(
      //   getToken() async => deps.authenticationController.token,
      //   logOut: () {
      //     l.w('Received "Not authenticated" HTTP response, logging out...');
      //     deps.authenticationController.logOut();
      //   }
      // ),
    ]);
  },
  'Restore last user': (deps) {
    // deps.authenticationController.restore();
  },

  // 'Get remote config': (_) {},
  // 'Restore settings': (deps) {},

  // 'Initialize localization': (_) {},

  // 'Prepare navigation': (deps) {
  //   deps.navigator = ValueNotifier<AppNavigationState>(
  //      const <AppPage>[MainPage()]
  //    );
  // },
  // 'Version repository': (deps) {
  //   deps.versionRepository = Config.fake
  //       ? VersionRepository$Fake()
  //       : VersionRepository$HttpImpl(client: deps.httpFactory());
  // },
  'Log app initialized': (_) {},
};

Future<Uri> _apiBaseUrlString(Dependencies deps) async {
  var apiBaseUrl = Config.apiBaseUrl;
  if (Config.isUrlFromLocaleStorage) {
    apiBaseUrl = await deps.prefs.getString('app_base_url') ?? apiBaseUrl;
    if (!apiBaseUrl.startsWith('https://') &&
        !apiBaseUrl.startsWith('http://')) {
      apiBaseUrl = Config.apiBaseUrl;
    }
    deps.prefs.setString('app_base_url', apiBaseUrl).ignore();
  }
  if (Config.apiBaseUrl != apiBaseUrl) {
    l.w('App url changed from ${Config.apiBaseUrl} to $apiBaseUrl');
  } else {
    l.i('App url: $apiBaseUrl');
  }
  return Uri.parse(apiBaseUrl);
}
