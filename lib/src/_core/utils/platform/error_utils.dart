import 'dart:io';

import 'package:starter/src/_core/config.dart';

String $errorToString(Object e) => switch (e) {
  HttpException() =>
    Config.environment.isProduction
        ? 'An network error occurred'
        : e.toString(),
  _ => Config.environment.isProduction ? 'An error occurred' : e.toString(),
};
