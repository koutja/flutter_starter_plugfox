import 'dart:io' as io;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:l/l.dart';

Future<void> $platformInitialization() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      l.d('Device is Android');
    case TargetPlatform.fuchsia:
      l.d('Device is Fuchsia');
    case TargetPlatform.iOS:
      l.d('Device is iOS');
    case TargetPlatform.linux:
      l.d('Device is Linux');
    case TargetPlatform.macOS:
      l.d('Device is MacOS');
    case TargetPlatform.windows:
      l.d('Device is Windows');
  }

  return io.Platform.isAndroid || io.Platform.isIOS
      ? _mobileInitialization()
      : _desktopInitialization();
}

Future<void> _mobileInitialization() async {
  // iOS and Android initialization
  final view = ui.PlatformDispatcher.instance.views.firstOrNull;
  if (view == null) {
    return;
  }
  final size = view.physicalSize / view.devicePixelRatio;
  if (size.shortestSide < 600) {
    l.d('Device is a phone with size: $size, setting portrait orientation');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } else {
    l.d('Device is a phone with size: $size, setting any orientation');
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
    ]);
  }
}

Future<void> _desktopInitialization() async {
  // macOS, Linux and Windows initialization
  l.d('Device is a desktop');
}

void $updateLoadingProgress({int progress = 100, String text = ''}) {}

void $removeLoadingWidget() {}
