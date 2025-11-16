import 'package:flutter/widgets.dart';

/// {@template scope}
/// PaymentScope widget.
/// {@endtemplate}
class PaymentScope extends StatefulWidget {
  /// {@macro scope}
  const PaymentScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<PaymentScope> createState() => _PaymentScopeState();
}

/// State for widget PaymentScope.
class _PaymentScopeState extends State<PaymentScope> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void didUpdateWidget(covariant PaymentScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget configuration changed
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The configuration of InheritedWidgets has changed
    // Also called after initState but before build
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => widget.child;
}
