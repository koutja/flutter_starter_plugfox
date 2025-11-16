import 'package:flutter/widgets.dart' show BuildContext;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/src/initialization/inherited_dependencies.dart';

/// Dependencies
class Dependencies {
  Dependencies();

  /// The state from the closest instance of this class.
  factory Dependencies.of(BuildContext context) =>
      InheritedDependencies.of(context);

  /// Shared preferences
  late final SharedPreferences sharedPreferences;
}
