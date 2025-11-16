import 'package:flutter/material.dart';

void main() {
  runApp(const Main());
}

/// {@template main}
/// Main widget.
/// {@endtemplate}
class Main extends StatelessWidget {
  /// {@macro main}
  const Main({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Placeholder(
        child: Text('UiKit'),
      ),
    );
  }
}
