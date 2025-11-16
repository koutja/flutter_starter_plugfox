import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:l/l.dart';
import 'package:starter/src/_core/analytics.dart';
import 'package:starter/src/_core/config.dart';
import 'package:starter/src/_core/util/error_util.dart';
/* import 'package:database/database.dart'; */
import 'package:starter/src/initialization/dependencies.dart';
import 'package:starter/src/initialization/initialize_dependencies.dart';
import 'package:starter/src/initialization/platform/platform_initialization.dart'
    as platform_initialization;

/// Ephemerally initializes the app and prepares it for use.
Future<Dependencies>? _$initializeApp;

/// Initializes the app and prepares it for use.
Future<Dependencies> $initializeApp({
  void Function(int progress, String message)? onProgress,
  FutureOr<void> Function(Dependencies dependencies)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) => _$initializeApp ??= Future<Dependencies>(() async {
  late final WidgetsBinding binding;
  final stopwatch = Stopwatch()..start();
  try {
    binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
    SemanticsBinding.instance.ensureSemantics();
    /* await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]); */
    await _catchExceptions();
    final deps = await $initializeDependencies(
      onProgress: onProgress,
    ).timeout(const Duration(minutes: 7));
    final metadata = deps.metadata;
    Analytics.instance
        .logEvent(
          'app',
          'open',
          parameters: <String, String>{
            'app_name': metadata.appName,
            'environment': Config.environment.name,
            'app_version': metadata.appVersion,
            'app_build_timestamp': metadata.appBuildTimestamp.toIso8601String(),
            'app_launched_timestamp': metadata.appLaunchedTimestamp
                .toIso8601String(),
            'device_screen_size': metadata.deviceScreenSize,
            'device_version': metadata.deviceVersion,
            'is_web': metadata.isWeb.toString(),
            'is_wasm': kIsWasm ? 'true' : 'false',
            'locale': metadata.locale,
            'operating_system': metadata.operatingSystem,
            'processors_count': metadata.processorsCount.toString(),
          },
        )
        .ignore();
    l.i('App initialized in ${stopwatch.elapsedMilliseconds}ms');
    await onSuccess?.call(deps);
    return deps;
  } on Object catch (e, st) {
    onError?.call(e, st);
    ErrorUtil.logError(
      e,
      st,
      hints: {
        'time': stopwatch.elapsedMilliseconds,
        'message': 'Failed to initialize app',
      },
    ).ignore();
    rethrow;
  } finally {
    stopwatch.stop();
    binding.addPostFrameCallback((_) {
      // Closes splash screen, and show the app layout.
      binding.allowFirstFrame();
      //final context = binding.renderViewElement;
      platform_initialization.$removeLoadingWidget();
    });
    _$initializeApp = null;
  }
});

/// Resets the app's state to its initial state.
@visibleForTesting
Future<void> $resetApp(Dependencies dependencies) async {}

/// Disposes the app and releases all resources.
@visibleForTesting
Future<void> $disposeApp(Dependencies dependencies) async {}

Future<void> _catchExceptions() async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      ErrorUtil.logError(
        error,
        stackTrace,
        hints: {
          'message': 'ROOT ERROR\r\n${Error.safeToString(error)}',
        },
      ).ignore();
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (details) {
      ErrorUtil.logError(
        details.exception,
        details.stack ?? StackTrace.current,
        hints: {
          'message': 'FLUTTER ERROR\r\n$details',
        },
      ).ignore();
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (e, st) {
    ErrorUtil.logError(e, st).ignore();
  }
}
