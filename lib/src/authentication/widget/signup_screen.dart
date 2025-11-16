import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

/// {@template signup_screen}
/// SignUpScreen widget.
/// {@endtemplate}
class SignUpScreen extends StatelessWidget {
  /// {@macro signup_screen}
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: math.max(16, (constraints.maxWidth - 620) / 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 50,
                  child: Text(
                    'Sign-Up',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge?.copyWith(height: 1),
                  ),
                ),
                const SizedBox.square(dimension: 32),
                const FormPlaceholder(),
                const SizedBox.square(dimension: 32),
                SizedBox(
                  height: 48,
                  child: _SignUpScreen$Buttons(
                    cancel: () => Navigator.pop(context),
                    signUp: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SignUpScreen$Buttons extends StatelessWidget {
  const _SignUpScreen$Buttons({
    required this.signUp,
    required this.cancel,
  });

  final void Function()? signUp;
  final void Function()? cancel;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: signUp,
          icon: const Icon(Icons.person_add),
          label: const Text(
            'Sign-Up',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      const SizedBox.square(dimension: 16),
      Expanded(
        child: FilledButton.tonalIcon(
          onPressed: cancel,
          icon: const Icon(Icons.cancel),
          label: const Text(
            'Cancel',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
}
