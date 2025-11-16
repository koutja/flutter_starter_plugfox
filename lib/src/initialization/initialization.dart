import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' /* deferred */
    as material
    show WidgetsFlutterBinding;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:sentry_flutter/sentry_flutter.dart' /* deferred */
    as sentry_flutter
    show SentryWidgetsFlutterBinding;
import 'package:starter/src/initialization/initialize_dependencies.dart';
import 'package:starter/src/initialization/platform/platform_initialization.dart'
    as platform_initialization;

@internal
Future<void> $initializeApp({
  void Function(int progress, String message)? onProgress,
  void Function(/* Dependencies dependencies */)? onSuccess,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  //await sentry_flutter.LoadLibrary();
  //await material. loadLibrary();
  // Defer the first frame until everything is initialized
  // and the app is ready to be displayed.

  final binding = material.WidgetsFlutterBinding.ensureInitialized()
    ..deferFirstFrame();
  SemanticsBinding.instance.ensureSemantics();
  final _ = sentry_flutter.SentryWidgetsFlutterBinding.ensureInitialized();
  try {
    // Handle errors that occur in the app
    // and send them as a breadcrumbs to Sentry.
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      // l.e("Top level error: $error', stackTrace);
      return true;
    };

    // Initialize application step by step
    final dependencies = await $initializeDependencies(onProgress: onProgress);
    Future<void> appRunner() async {
      // Allow the first frame to be displayed after the app is initialized.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        binding.allowFirstFrame();
        // platform_initialization.$removeLoadingWidget();
        // l.i('App initialized successfully. ');
        onSuccess?.call();
        // Analytics.instance.logEvent(
        //   "app",
        //   "open",
        //   parameters: <String, String>{},
        // );
      });
    }
  } on Object catch (e, st) {
    onError?.call(e, st);
  }
}
