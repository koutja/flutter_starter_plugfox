import 'package:l/l.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/src/_core/utils/pubspec.yaml.g.dart';

// export 'platform/app_migrator_vm.dart'
//     if (dart.library.js_interop) 'platform/app_migrator_js.dart'
//     show migratorDropDatabase;

sealed class AppMigrator {
  static const storageNamespace = 'app.migrator';
  static const versionKey = '$storageNamespace.version';

  static Future<void> migrate(SharedPreferencesAsync prefs) async {
    try {
      final versionString = await prefs.getString(versionKey);
      if (versionString == null) {
        l.d('Initializing app for the first time');
      } else {
        final prevVersion = Version.parse(versionString);
        final currVersion = Version.parse(Pubspec.version.canonical);
        if (prevVersion.major != currVersion.major ||
            prevVersion.minor != currVersion.minor ||
            prevVersion.patch != currVersion.patch) {
          l.d('Migrating app from version $prevVersion to $currVersion');
          await prefs.remove('api_base_url');
          // await migratorDropDatabase();
        } else {
          l.d('App is up to date');
          return;
        }
      }
      await prefs.setString(versionKey, Pubspec.version.canonical);
    } on Object catch (e, st) {
      l.e('App migration failed: $e', st);
      rethrow;
    }
  }
}
