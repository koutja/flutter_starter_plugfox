import 'package:control/control.dart';
import 'package:meta/meta.dart';
import 'package:pub_semver/pub_semver.dart';

final class CheckVersionController extends StateController<CheckVersionState>
    with DroppableControllerHandler {
  CheckVersionController(
    this.repository, {
    super.initialState = const _Idle(),
  });

  final Object repository;

  @awaitNotRequired
  Future<void> checkVersion({
    required void Function(CheckVersionEntity) onSuccess,
    required void Function(Object, StackTrace) onError,
  }) async {
    // final version = await repository.getVersion();
    // if (version != null) {
    //   // Check the version
    // }
    final entity = CheckVersionEntity(
      updateUrl: null,
      currentVersion: Version.parse('1.0.0'),
      latestVersion: Version.parse('2.0.0'),
      compatible: true,
      updateAvailable: false,
    );
    onSuccess(entity);
  }
}

final class CheckVersionEntity {
  const CheckVersionEntity({
    required this.updateUrl,
    required this.currentVersion,
    required this.latestVersion,
    required this.compatible,
    required this.updateAvailable,
  });

  final String? updateUrl;
  final Version currentVersion;
  final Version latestVersion;
  final bool compatible;
  final bool updateAvailable;
}

sealed class CheckVersionState {
  const CheckVersionState();
}

final class _Idle extends CheckVersionState {
  const _Idle();
}
