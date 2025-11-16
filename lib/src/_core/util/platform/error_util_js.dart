// ignore_for_file: avoid_positional_boolean_parameters

Future<void> $captureException(
  Object exception,
  StackTrace stackTrace,
  Map<String, Object?>? hints,
  bool fatal,
) => Future<void>.value();

Future<void> $captureMessage(
  String message,
  StackTrace? stackTrace,
  Map<String, Object?>? hints,
  bool warning,
) => Future<void>.value();
