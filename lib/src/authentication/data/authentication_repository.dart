import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:starter/src/authentication/model/sign_in_data.dart';
import 'package:starter/src/authentication/model/user.dart';

abstract interface class AuthenticationRepository {
  Stream<User> userChanges();
  FutureOr<User> getUser();
  Future<void> signIn(SignInData data);
  Future<void> restore();
  Future<void> signOut();
}

class AuthenticationRepository$Fake implements AuthenticationRepository {
  AuthenticationRepository$Fake({
    required SharedPreferencesAsync prefs,
  }) : _prefs = prefs;

  static const String _sessionKey = 'authentication.session';
  final SharedPreferencesAsync _prefs;
  final StreamController<User> _userController =
      StreamController<User>.broadcast();
  User _user = const User.unauthenticated();

  @override
  FutureOr<User> getUser() => _user;

  @override
  Stream<User> userChanges() => _userController.stream;

  @override
  Future<void> signIn(SignInData data) => Future<void>.delayed(
    const Duration(seconds: 1),
    () {
      final user = User.authenticated(id: data.username);
      _prefs.setString(_sessionKey, jsonEncode(user.toJson())).ignore();
      _userController.add(_user = user);
    },
  );

  @override
  Future<void> restore() async {
    final session = await _prefs.getString(_sessionKey);
    if (session == null) return;
    final json = jsonDecode(session);
    if (json case final Map<String, Object?> jsonMap) {
      final user = User.fromJson(jsonMap);
      _userController.add(_user = user);
    }
  }

  @override
  Future<void> signOut() => Future<void>.sync(
    () {
      const user = User.unauthenticated();
      _prefs.remove(_sessionKey).ignore();
      _userController.add(_user = user);
    },
  );
}
