import 'dart:async';

import 'package:control/control.dart';
import 'package:meta/meta.dart';
import 'package:starter/src/authentication/controller/authentication_state.dart';
import 'package:starter/src/authentication/data/authentication_repository.dart';
import 'package:starter/src/authentication/model/sign_in_data.dart';
import 'package:starter/src/authentication/model/user.dart';

final class AuthenticationController
    extends StateController<AuthenticationState>
    with DroppableControllerHandler {
  AuthenticationController({
    required AuthenticationRepository repository,
    super.initialState = const AuthenticationState.idle(
      user: UserEntity.unauthenticated(),
    ),
  }) : _repository = repository {
    _userSubscription = repository
        .userChanges()
        .map<AuthenticationState>((u) => AuthenticationState.idle(user: u))
        .where(
          (newState) =>
              state.isProcessing || !identical(newState.user, state.user),
        )
        .listen(setState, cancelOnError: false);
  }

  final AuthenticationRepository _repository;
  StreamSubscription<AuthenticationState>? _userSubscription;

  /// Restore the session from the cache.
  void restore() => handle(
    () async {
      setState(
        AuthenticationState.processing(
          user: state.user,
          message: 'Restoring session...',
        ),
      );
      await _repository.restore();
    },
    error: (_, _) async => setState(
      const AuthenticationState.idle(
        user: UserEntity.unauthenticated(),
        message: 'Restore Error',
        // error: ErrorUtil.formatMessage(e),
      ),
    ),
    done: () async => setState(
      AuthenticationState.idle(user: state.user),
    ),
  );

  /// Sign in with the given [data].
  void signIn(SignInData data) => handle(
    () async {
      setState(
        AuthenticationState.processing(
          user: state.user,
          message: 'Logging in...',
        ),
      );
      await _repository.signIn(data);
    },
    error: (_, _) async => setState(
      AuthenticationState.idle(
        user: state.user,
        error: 'Sign In Error', // ErrorUtil.formatMessage(error)
      ),
    ),
    done: () async => setState(
      AuthenticationState.idle(user: state.user),
    ),
  );

  /// Sign out.
  void signOut() => handle(
    () async {
      setState(
        AuthenticationState.processing(
          user: state.user,
          message: 'Logging out...',
        ),
      );
      await _repository.signOut();
    },
    error: (_, _) async => setState(
      AuthenticationState.idle(
        user: state.user,
        error: 'Log Out Error', // ErrorUtil.formatMessage(error)
      ),
    ),
    done: () async => setState(
      const AuthenticationState.idle(
        user: UserEntity.unauthenticated(),
      ),
    ),
  );

  @override
  @awaitNotRequired
  Future<void> dispose() async {
    await _userSubscription?.cancel();
    _userSubscription = null;
    super.dispose();
  }
}
