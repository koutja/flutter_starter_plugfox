import 'dart:js_interop';

import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:l/l.dart';
import 'package:web/web.dart' as web;

//import 'package:flutter_web_plugins/url_strategy.dart';
//import 'package:flutter_web_plugins/flutter_web_plugins.dart';

extension type $JSWindow._(JSObject _) implements JSObject {
  external void updateLoadingProgress(int progress, String text);

  external void removeLoadingProgress();
}

@JS('window')
external $JSWindow get widget;

Future<void> $platformInitialization() async {
  try {
    usePathUrlStrategy();
  } on Object catch (e, st) {
    l.w('Failed to set URL strategy: $e', st);
  }
  try {
    if (kIsWeb) BrowserContextMenu.disableContextMenu().ignore();
  } on Object catch (e, st) {
    l.w('Failed to disable browser context menu: $e', st);
  }
  try {
    if (kIsWeb) FilePickerWeb.registerWith(Registrar());
  } on Object catch (e, st) {
    l.w('Failed to disable browser context menu: $e', st);
  }

  // Remove splash screen
  Future<void>.delayed(
    const Duration(seconds: 1),
    () {
      try {
        final loading = web.document.getElementsByClassName('loading');
        for (var i = loading.length - 1; i >= 0; i--) {
          loading.item(i)?.remove();
        }
      } on Object catch (e, st) {
        l.w('Failed to remove loading screen: $e', st);
      }

      try {
        web.document.getElementById('splash')?.remove();
        web.document.getElementById('splash-branding')?.remove();
        web.document.body?.style.background = 'transparent';
        final elements = web.document.getElementsByClassName('splash-loading');
        for (var i = elements.length - 1; i >= 0; i--) {
          elements.item(i)?.remove();
        }
      } on Object catch (e, st) {
        l.w('Failed to remove splash screen: $e', st);
      }
    },
  );

  try {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        l.d('Device is Android');
      case TargetPlatform.fuchsia:
        l.d('Device is Fuchsia');
      case TargetPlatform.iOS:
        l.d('Device is iOS');
        // This is a workaround for the iOS Safari bug where the viewport size
        // does not update when the keyboard is shown.
        web.window.visualViewport?.addEventListener(
          'resize',
          (web.Event e) {
            web.window.dispatchEvent(web.Event('resize'));
          }.toJS,
        );
      case TargetPlatform.linux:
        l.d('Device is Linux');
      case TargetPlatform.macOS:
        l.d('Device is MacOS');
        // This is a workaround for the iOS Safari bug where the viewport size
        // does not update when the keyboard is shown.
        web.window.visualViewport?.addEventListener(
          'resize',
          (web.Event e) {
            web.window.dispatchEvent(web.Event('resize'));
          }.toJS,
        );
      case TargetPlatform.windows:
        l.d('Device is Windows');
    }
  } on Object catch (e, st) {
    l.w('Error during platform pre initialization $e', st);
  }
}

/* class NoHistoryUrlStrategy extends PathUrlStrategy {
  @override
  void pushState(Object? state, String title, String url) =>
      replaceState(state, title, url);
}
*/
