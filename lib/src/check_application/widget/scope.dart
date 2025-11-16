import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/src/check_application/controller/check_versions_controller.dart';
import 'package:starter/src/check_application/widget/update_vm.dart'
    if (dart.library.js_interop) 'package:starter/src/check_application/widget/update_js.dart'
    as update;
import 'package:starter/src/initialization/dependencies.dart';

/// {@template scope}
/// CheckApplicationScope widget.
/// {@endtemplate}
class CheckApplicationScope extends StatefulWidget {
  /// {@macro scope}
  const CheckApplicationScope({
    required this.checkVersion,
    required this.child,
    super.key,
  });

  final bool checkVersion;
  final Widget child;

  @override
  State<CheckApplicationScope> createState() => _CheckApplicationScopeState();
}

/// State for widget CheckApplicationScope.
class _CheckApplicationScopeState extends State<CheckApplicationScope> {
  late final CheckVersionController _controller;
  late final SharedPreferencesAsync _prefs;
  Timer? _periodicCheck;
  OverlayEntry? _overlayEntry;
  Version? _skipVersion;
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    final deps = Dependencies.of(context);
    _prefs = deps.prefs;
    _controller = CheckVersionController(deps.versionRepository);
    // Check new version every hour
    _periodicCheck = Timer.periodic(
      const Duration(hours: 1),
      (timer) => _maybeCheckVersion(),
    );
    // Check the version Immediately
    _maybeCheckVersion();
    _initSkipVersion();
  }

  @override
  void didUpdateWidget(covariant CheckApplicationScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checkVersion != widget.checkVersion && widget.checkVersion) {
      _maybeCheckVersion();
    }
  }

  @override
  void dispose() {
    _periodicCheck?.cancel();
    _controller.dispose();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => widget.child;

  void _displayUpdateOverlay(CheckVersionEntity entity) {
    _overlayEntry?.remove();
    if (entity.compatible && _skipVersion != entity.latestVersion) {
      return;
    }
    final updateUrl = entity.updateUrl ?? 'https://update-domain.com';
    final entry = _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: entity.compatible
            ? _NewUpdateAvailableDialog(
                version: entity.latestVersion,
                updateNow: () {
                  update.openUpdateUrl(updateUrl);
                },
                maybeLater: () async {
                  _overlayEntry?.remove();
                  _overlayEntry = null;
                  _saveSkipVersion(entity.latestVersion);
                },
              )
            : _UpdateRequiredDialog(
                version: entity.latestVersion,
                updateNow: () {
                  update.openUpdateUrl(updateUrl);
                },
              ),
      ),
    );
    Overlay.maybeOf(context)?.insert(entry);
  }

  @awaitNotRequired
  Future<void> _maybeCheckVersion() async {
    if (!mounted) return;
    if (!widget.checkVersion) return;
    // Check if the overlay entry is already mounted
    if (_overlayEntry case OverlayEntry(mounted: true)) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.checkVersion(
        onSuccess: (entity) {
          _overlayEntry?.remove();
          _overlayEntry = null;
          if (!entity.updateAvailable) return;
          _displayUpdateOverlay(entity);
        },
        onError: (e, st) {
          l.w('Failed to check version: $e', st);
          // Try again in 15 minutes
          Timer(
            const Duration(minutes: 15),
            _maybeCheckVersion,
          );
        },
      );
    });
  }

  @awaitNotRequired
  Future<Version> _initSkipVersion() async {
    final skipVersion = await _prefs.getString('update_skip_version');
    return Version.parse(skipVersion ?? '0.0.0');
  }

  @awaitNotRequired
  Future<void> _saveSkipVersion(Version skipVersion) async {
    _skipVersion = skipVersion;
    await _prefs.setString(
      'update_skip_version',
      skipVersion.canonicalizedVersion,
    );
  }
}

class _NewUpdateAvailableDialog extends StatelessWidget {
  const _NewUpdateAvailableDialog({
    required this.version,
    required this.updateNow,
    required this.maybeLater,
  });

  final Version version;
  final VoidCallback updateNow;
  final VoidCallback maybeLater;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: .center,
    fit: .expand,
    children: <Widget>[
      const Positioned.fill(
        key: Key('update_barrier'),
        child: AbsorbPointer(
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
      ),
      const Center(child: Text('New update available')),
      Positioned(
        bottom: 0,
        child: ElevatedButton(
          onPressed: updateNow,
          child: const Text('Update now'),
        ),
      ),
    ],
  );
}

class _UpdateRequiredDialog extends StatelessWidget {
  const _UpdateRequiredDialog({
    required this.version,
    required this.updateNow,
  });

  final Version version;
  final VoidCallback updateNow;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Update required'),
    content: const Text(
      'A new version of the app is required. Do you want to update now?',
    ),
    actions: <Widget>[
      TextButton(
        onPressed: updateNow,
        child: const Text('Update now'),
      ),
    ],
  );
}
