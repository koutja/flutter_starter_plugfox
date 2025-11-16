import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:starter/src/_core/pages.dart';

typedef AppNavigatorGuard =
    AppNavigationState Function(BuildContext context, AppNavigationState state);

typedef AppNavigatorTitleGuard = AppNavigatorGuard;

typedef AppNavigatorAnalyticsGuard = AppNavigatorGuard;

typedef AppNavigationState = List<AppPage>;

@immutable
class AppNavigator extends StatefulWidget {
  AppNavigator({
    required this.pages,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    super.key,
  }) : assert(pages.isNotEmpty, 'pages cannot be empty'),
       controller = null;

  AppNavigator.controlled({
    required ValueNotifier<List<AppPage>> this.controller,
    this.guards = const [],
    this.observers = const [],
    this.transitionDelegate = const DefaultTransitionDelegate<Object?>(),
    this.revalidate,
    super.key,
  }) : assert(controller.value.isNotEmpty, 'controller.cannot be empty'),
       pages = controller.value;

  static AppNavigatorState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppNavigatorState>();

  static AppNavigationState? stateOf(BuildContext context) =>
      maybeOf(context)?.state;

  static NavigatorState? navigatorOf(BuildContext context) =>
      maybeOf(context)?.navigator;

  static void change(
    BuildContext context,
    AppNavigationState Function(AppNavigationState pages) fn,
  ) {
    maybeOf(context)?.change(fn);
  }

  static void push(BuildContext context, AppPage page) {
    change(context, (state) => [...state, page]);
  }

  static void pop(BuildContext context) {
    change(context, (state) {
      if (state.isEmpty) {
        return state;
      }
      state.removeLast();
      return state;
    });
  }

  /// Clear the pages to the initial state.
  static void reset(BuildContext context) {
    final navigator = maybeOf(context);
    if (navigator == null) {
      return;
    }
    navigator.change((_) => navigator.widget.pages);
  }

  final AppNavigationState pages;

  final ValueNotifier<AppNavigationState>? controller;

  final List<AppNavigatorGuard> guards;

  final List<NavigatorObserver> observers;

  final TransitionDelegate<Object?> transitionDelegate;

  final Listenable? revalidate;

  @override
  State<AppNavigator> createState() => AppNavigatorState();
}

class AppNavigatorState extends State<AppNavigator> {
  late final _observer = NavigatorObserver();

  /// Current [Navigator] state (null if not yet built)
  NavigatorState? get navigator => _observer.navigator;

  late AppNavigationState _state;

  AppNavigationState get state => _state;

  List<NavigatorObserver> _observers = const [];

  @override
  void initState() {
    super.initState();
    _state = widget.pages;
    widget.revalidate?.addListener(_revalidateListener);
    _observers = [_observer, ...widget.observers];
    widget.controller?.addListener(_controllerListener);
    _controllerListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _revalidateListener();
  }

  @override
  void didUpdateWidget(covariant AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.revalidate, oldWidget.revalidate)) {
      oldWidget.revalidate?.removeListener(_revalidateListener);
      widget.revalidate?.addListener(_revalidateListener);
    }
    if (!identical(widget.observers, oldWidget.observers)) {
      _observers = [_observer, ...widget.observers];
    }
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?.removeListener(_controllerListener);
      widget.controller?.addListener(_controllerListener);
      _controllerListener();
    }
  }

  @override
  void dispose() {
    widget.revalidate?.removeListener(_revalidateListener);
    widget.controller?.removeListener(_controllerListener);
    super.dispose();
  }

  void _setStateToController() {
    if (widget.controller
        case final ValueNotifier<AppNavigationState> controller) {
      controller
        ..removeListener(_controllerListener)
        ..value = _state
        ..addListener(_controllerListener);
    }
  }

  void _controllerListener() {
    final controller = widget.controller;
    if (controller == null || !mounted) {
      return;
    }
    final newValue = controller.value;
    if (identical(newValue, _state)) {
      return;
    }
    final ctx = context;
    final next = widget.guards.fold(newValue.toList(), (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) {
      _setStateToController();
      return;
    }
    _state = UnmodifiableListView(next);
    _setStateToController();
    setState(() {});
  }

  void revalidate() {
    if (!mounted) {
      return;
    }
    _validate(_state);
  }

  void _revalidateListener() {
    revalidate();
  }

  void change(AppNavigationState Function(AppNavigationState pages) fn) {
    final prev = _state.toList();
    final newValue = fn(prev);
    _validate(newValue);
  }

  void _validate(AppNavigationState value) {
    if (value.isEmpty) {
      return;
    }
    if (!mounted) {
      return;
    }
    final ctx = context;
    final next = widget.guards.fold(value, (s, g) => g(ctx, s));
    if (next.isEmpty || listEquals(next, _state)) {
      return;
    }
    _state = UnmodifiableListView(next);
    _setStateToController();
    setState(() {});
  }

  void _onDidRemovePage(Page<Object?> page) =>
      change((pages) => pages..removeWhere((p) => p.key == page.key));

  @override
  Widget build(BuildContext context) => Navigator(
    pages: _state,
    // reportsRouteUpdateToEngine: false,
    transitionDelegate: widget.transitionDelegate,
    onDidRemovePage: _onDidRemovePage,
    observers: _observers,
  );
}
