import 'dart:async';

import 'package:control/control.dart';
import 'package:l/l.dart';
import 'package:meta/meta.dart';
import 'package:starter/src/_core/util/error_util.dart';

/// Observer for [Controller], react to changes in the any controller.
final class GlobalControllerObserver implements IControllerObserver {
  const GlobalControllerObserver();

  @override
  void onCreate(Controller controller) {
    l.v6('Controller | ${controller.name}.new');
  }

  @override
  void onDispose(Controller controller) {
    l.v5(
      '${controller is StateController ? 'StateController' : 'Controller'}'
      ' | ${controller.name}.dispose',
    );
  }

  @override
  void onHandler(HandlerContext context) {
    final stopwatch = Stopwatch()..start();
    final controller = context.controller;
    l.d(
      '${controller is StateController ? 'StateController' : 'Controller'}'
      ' | ${controller.name}.${context.name}',
      context.meta,
    );
    _doneHandler(context, stopwatch);
  }

  @awaitNotRequired
  Future<void> _doneHandler(HandlerContext context, Stopwatch stopwatch) async {
    final controller = context.controller;
    await context.done.whenComplete(() {
      stopwatch.stop();
      l.d(
        '${controller is StateController ? 'StateController' : 'Controller'}'
        '| ${context.controller.name}.${context.name} | '
        'duration: ${stopwatch.elapsed}',
        context.meta,
      );
    });
  }

  @override
  void onStateChanged<S extends Object>(
    StateController<S> controller,
    S prevState,
    S nextState,
  ) {
    final context = Controller.context;
    if (context == null) {
      // State change occurred outside of the handler
      l.d(
        'StateController | '
        '${controller.name} | '
        '$prevState -> $nextState',
      );
    } else {
      // State change occurred inside the handler
      l.d(
        'StateController | '
        '${controller.name}.${context.name} | '
        '$prevState -> $nextState',
        context.meta,
      );
    }
  }

  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    final context = Controller.context;
    ErrorUtil.logError(error, stackTrace, hints: context?.meta).ignore();
    if (context == null) {
      // Error occurred outside of the handler
      l.w(
        '${controller is StateController ? 'StateController' : 'Controller'}'
        '| ${controller.name} | '
        '$error',
        stackTrace,
      );
    } else {
      // Error occurred inside the handler
      l.w(
        '${controller is StateController ? 'StateController' : 'Controller'}'
        '| ${controller.name}.${context.name} | '
        '$error',
        stackTrace,
        context.meta,
      );
    }
  }
}
