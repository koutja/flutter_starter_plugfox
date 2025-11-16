import 'package:db/database_interface.dart';
import 'package:flutter/widgets.dart' show BuildContext, Key, Widget;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/src/authentication/controller/authentication_controller.dart';
import 'package:starter/src/initialization/app_metadata.dart';
import 'package:starter/src/initialization/widget/inherited_dependencies.dart';

/// Dependencies
class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);

  Widget inject({required Widget child, Key? key}) => InheritedDependencies(
    dependencies: this,
    key: key,
    child: child,
  );

  late final AppMetadata metadata;

  /// Shared preferences
  late final SharedPreferencesAsync prefs;

  late final AuthenticationController authenticationController;

  late final KeyValueStorage keyValueStorage;

  // TODO: Change Object to HttpClient
  late final Object Function([Iterable<Object>? middlewares]) httpFactory;

  // TODO: Change Object to HttpClient
  late final Object httpClient;

  // TODO: Проверка актуальной версии приложения
  late final Object versionRepository;
}
