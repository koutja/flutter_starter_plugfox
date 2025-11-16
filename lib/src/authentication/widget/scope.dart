import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:starter/src/_core/analytics.dart';
import 'package:starter/src/_core/extensions/inherited_extension.dart';
import 'package:starter/src/_core/pages.dart';
import 'package:starter/src/authentication/controller/authentication_controller.dart';
import 'package:starter/src/authentication/controller/authentication_state.dart';
import 'package:starter/src/authentication/model/sign_in_data.dart';
import 'package:starter/src/authentication/model/user.dart';
import 'package:starter/src/authentication/widget/signup_screen.dart';
import 'package:starter/src/initialization/dependencies.dart';

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthenticationScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthenticationScope({
    required this.child,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  static _InheritedAuthenticationScope _readScopeOf(BuildContext context) =>
      context.inhOf(listen: false);

  static _InheritedAuthenticationScope _watchScopeOf(BuildContext context) =>
      context.inhOf();

  /// Get the current [AuthenticationController]
  static AuthenticationController controllerOf(BuildContext context) =>
      _readScopeOf(context).controller;

  /// Get the current [AuthenticationState]
  static AuthenticationState readStateOf(BuildContext context) =>
      _readScopeOf(context).state;

  static AuthenticationState watchStateOf(BuildContext context) =>
      _watchScopeOf(context).state;

  /// Get the current [UserEntity]
  static UserEntity readUserOf(BuildContext context) =>
      readStateOf(context).user;

  static UserEntity watchUserOf(BuildContext context) =>
      watchStateOf(context).user;

  /// Sign-In
  static void signIn(BuildContext context, SignInData data) =>
      controllerOf(context).signIn(data);

  /// Sign-Out
  static void signOut(BuildContext context) => controllerOf(context).signOut();

  /// Check if the user is authenticated and call the given [authenticated]
  /// if the user is authenticated.
  /// If the user is not authenticated, call the given fallback [orElse].
  ///
  /// This method is safe to use inside "initState" or "didChangeDependencies"
  /// and do not add any dependency to the provided [context] element.
  static AuthenticatedUser? authenticateOr(
    BuildContext context, {
    void Function(AuthenticatedUser user)? authenticated,
    void Function(AuthenticationController controller)? orElse,
  }) {
    final current = readUserOf(context);
    if (current case final AuthenticatedUser user) {
      authenticated?.call(user);
      return user;
    }
    orElse?.call(controllerOf(context));
    return null;
  }

  static void navigate(
    BuildContext context,
    List<Page<Object?>> Function(List<Page<Object?>> pages) change,
  ) => _readScopeOf(context).scope.navigate(change);

  @override
  State<AuthenticationScope> createState() => _AuthenticationScopeState();
}

/// State for widget AuthenticationScope.
class _AuthenticationScopeState extends State<AuthenticationScope> {
  late final _deps = Dependencies.of(context);
  late final Analytics _analytics = _deps.analytics;
  late final ValueNotifier<List<AppPage>> _appNavigator = _deps.navigator;
  late final AuthenticationController controller =
      _deps.authenticationController;
  late AuthenticationState currentAuthenticationState;
  UserEntity get currentUser => currentAuthenticationState.user;

  static const List<Page<Object?>> _initialPages = [
    MaterialPage(
      key: ValueKey('sign_up'),
      name: 'sign_up',
      child: SignUpScreen(),
    ),
  ];

  List<Page<Object?>> _pages = _initialPages;

  @override
  void initState() {
    super.initState();
    controller.addListener(_authStateListener);
    currentAuthenticationState = controller.state;
    _setUserProfile(currentUser);
  }

  @override
  void dispose() {
    controller.removeListener(_authStateListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InheritedAuthenticationScope(
    key: ValueKey(currentUser.id),
    controller: controller,
    state: controller.state,
    scope: this,
    child: currentUser.isAuthenticated
        ? widget.child
        : Title(
            title: const <String>[
              // TODO(koutja): Add l10n
              // AppLocalization.of(context).title,
              // SignUpLocalization.of(context).title,
            ].join(' | '),
            color: Theme.of(context).primaryColor,
            child: Navigator(
              onDidRemovePage: _didRemovePageHandler,
              // TODO(koutja): Add Observer
              // observers: const <NavigatorObserver>[

              // ],
              pages: _pages,
            ),
          ),
  );

  @awaitNotRequired
  Future<void> _setUserProfile(UserEntity u) async {
    await _analytics.setUserId(u.id);
    final toggleConsent = (u.isAuthenticated)
        ? _analytics.enableConsent
        : _analytics.disableConsent;
    await toggleConsent();
  }

  @awaitNotRequired
  Future<void> _logAuthenticated(UserEntity u) async {
    await _setUserProfile(u);
    await _analytics.logEvent(
      'authentication',
      'authenticated',
      parameters: {'name': u.id ?? ''},
    );
  }

  @awaitNotRequired
  Future<void> _logNotAuthenticated() async {
    await _analytics.setUserId(null);
    await _analytics.logEvent(
      'authentication',
      'not_authenticated',
    );
  }

  void navigate(
    List<Page<Object?>> Function(List<Page<Object?>> pages) change,
  ) {
    var newPages = change(_pages.toList()).toList(growable: true);
    if (newPages.isEmpty) {
      newPages = _initialPages;
    }
    if (listEquals(newPages, _pages)) {
      return;
    }
    setState(() {
      _pages = newPages;
    });
  }

  void _didRemovePageHandler(Page<Object?> page) {
    _pages = _pages.where((p) => p.key != page.key).toList(growable: false);
  }

  void _authStateListener() {
    if (!mounted) return;
    final prevState = currentAuthenticationState;
    final nextState = controller.state;
    if (!identical(prevState.user.id, nextState.user.id)) {
      l.d('User changed: ${prevState.user} -> ${nextState.user}');
    }
    currentAuthenticationState = nextState;
    final u = nextState.user;
    if (u.isAuthenticated) {
      _pages = _initialPages;
      _logAuthenticated(u);
    } else {
      _appNavigator.value = const <AppPage>[
        // TODO(koutja): Insert FeaturePage()
      ];
      _logNotAuthenticated();
    }
    setState(() {});
  }
}

enum _AuthenticationAccept {
  none,
  state,
  user,
  id,
}

class _InheritedAuthenticationScope
    extends InheritedModel<_AuthenticationAccept> {
  const _InheritedAuthenticationScope({
    required this.controller,
    required this.state,
    required this.scope,
    required super.child,
    super.key,
  });

  final AuthenticationController controller;
  final AuthenticationState state;
  final _AuthenticationScopeState scope;

  UserEntity get user => state.user;

  static _InheritedAuthenticationScope? maybeOf(
    BuildContext context, {
    _AuthenticationAccept aspect = _AuthenticationAccept.none,
  }) => switch (aspect) {
    _AuthenticationAccept.none => context.inhMaybeOf(listen: false),
    _AuthenticationAccept.state => context.inhMaybeOf(listen: true),
    _AuthenticationAccept.user => context.maybeInheritFrom(aspect: aspect),
    _AuthenticationAccept.id => context.maybeInheritFrom(aspect: aspect),
  };

  static _InheritedAuthenticationScope of(
    BuildContext context, {
    _AuthenticationAccept aspect = _AuthenticationAccept.none,
  }) =>
      maybeOf(context, aspect: aspect) ??
      (throw ArgumentError(
        'Out of scope, not found inherited model '
            'a _InheritedAuthenticationScope of the exact type '
            'Make sure to use AuthenticationScope as a parent of this widget.',
        'out_of_scope',
      ));

  @override
  bool updateShouldNotify(covariant _InheritedAuthenticationScope oldWidget) =>
      !identical(oldWidget.user, user);

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedAuthenticationScope oldWidget,
    Set<_AuthenticationAccept> dependencies,
  ) {
    for (final aspect in dependencies) {
      switch (aspect) {
        case _AuthenticationAccept.state
            when !identical(oldWidget.state, state):
          // Notify about changes in the state
          return true;
        case _AuthenticationAccept.user when !identical(oldWidget.user, user):
          // Notify about changes in the user data
          return true;
        case _AuthenticationAccept.id when oldWidget.user.id != user.id:
          // Notify about changes in the user id
          return true;
        default:
          continue;
      }
    }
    return false;
  }
}
