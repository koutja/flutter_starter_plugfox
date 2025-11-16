import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class AppPage extends MaterialPage<void> with EquatableMixin {
  const AppPage({
    required String super.name,
    required Map<String, Object?>? super.arguments,
    required super.child,
    required LocalKey super.key,
  });

  @override
  String get name => super.name ?? 'Unknown';

  @override
  Map<String, Object?> get arguments => switch (super.arguments) {
    final Map<String, Object?> args when args.isNotEmpty => args,
    _ => const <String, Object?>{},
  };

  @override
  List<Object?> get props => [super.key];
}

final class HomePage extends AppPage {
  const HomePage()
    : super(
        name: 'home',
        arguments: null,
        child: const Text('HomeScreen'),
        key: const ValueKey('home'),
      );
}

final class PaywallPage extends AppPage {
  const PaywallPage()
    : super(
        name: 'paywall',
        arguments: null,
        child: const Text('PaywallScreen'),
        key: const ValueKey('paywall'),
      );
}
