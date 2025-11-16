import 'dart:async';

import 'package:l/l.dart';
import 'package:starter/src/_core/util/platform/error_util_vm.dart'
    if (dart.library.js_interop) 'package:starter/src/_core/util/platform/error_util_js.dart';

/// Error util.
abstract final class ErrorUtil {
  /// Log the error to the console and to Crashlytics.
  static Future<void> logError(
    Object exception,
    StackTrace stackTrace, {
    Map<String, Object?>? hints,
    bool fatal = false,
  }) async {
    try {
      if (exception is String) {
        return await logMessage(
          exception,
          stackTrace: stackTrace,
          hints: hints,
          warning: true,
        );
      }
      $captureException(exception, stackTrace, hints, fatal).ignore();
      l.e(exception, stackTrace);
    } on Object catch (e, st) {
      l.e(
        'Error while logging error "$e" inside ErrorUtil.logError',
        st,
      );
    }
  }

  /// Logs a message to the console and to Crashlytics.
  static Future<void> logMessage(
    String message, {
    StackTrace? stackTrace,
    Map<String, Object?>? hints,
    bool warning = false,
  }) async {
    try {
      l.e(message, stackTrace ?? StackTrace.current);
      $captureMessage(message, stackTrace, hints, warning).ignore();
    } on Object catch (e, st) {
      l.e(
        'Error while logging error "$e" inside ErrorUtil.logMessage',
        st,
      );
    }
  }

  /// Rethrows the error with the stack trace.
  static Never throwWithStackTrace(Object error, StackTrace stackTrace) =>
      Error.throwWithStackTrace(error, stackTrace);
}
