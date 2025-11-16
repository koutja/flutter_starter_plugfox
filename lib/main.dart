import 'dart:async' show runZonedGuarded;

import 'package:flutter/widgets.dart';
import 'package:l/l.dart';
import 'package:starter/src/_core/util/error_util.dart';
import 'package:starter/src/_core/util/log_buffer.dart';
import 'package:starter/src/_core/widget/app.dart' deferred as app;
import 'package:starter/src/_core/widget/app_error.dart' deferred as app_error;
import 'package:starter/src/initialization/initialization.dart'
    deferred as initialization;

void main() => l.capture<void>(
  () => runZonedGuarded<void>(
    () async {
      // Splash screen
      final initializationProgress =
          ValueNotifier<({int progress, String message})>((
            progress: 0,
            message: '',
          ));
      /* runApp(SplashScreen(progress: initializationProgress)); */
      await initialization.loadLibrary();
      // await inherited_dependencies.loadLibrary();
      await app.loadLibrary();
      initialization
          .$initializeApp(
            onProgress: (progress, message) => initializationProgress.value = (
              progress: progress,
              message: message,
            ),
            onSuccess: (dependencies) => runApp(
              dependencies.inject(
                child: app.App(),
              ),
            ),
            onError: (error, stackTrace) async {
              await app_error.loadLibrary();
              runApp(app_error.AppError(error: error));
              ErrorUtil.logError(error, stackTrace).ignore();
            },
          )
          .ignore();
    },
    l.e,
  ),
  const LogOptions(
    messageFormatting: _messageFormatting,
  ),
);

Object _messageFormatting(LogMessage log) {
  LogBuffer.instance.add(log);
  final prefix = log.level.when(
    // Verbose and so on
    v: () => '1️⃣',
    vv: () => '2️⃣',
    vvv: () => '3️⃣',
    vvvv: () => '4️⃣',
    vvvvv: () => '5️⃣',
    vvvvvv: () => '6️⃣',
    // Standard log levels
    debug: () => '🐛', // debug messages
    info: () => 'ℹ️', // info messages
    warning: () => '⚠️', // warnings
    error: () => '❌', // errors
    shout: () => '🚨', // critical messages
  );

  return '$prefix '
      '${_timeFormat(log.timestamp)} '
      '| ${log.message}';
}

String _timeFormat(DateTime time) =>
    '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
