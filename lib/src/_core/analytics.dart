import 'dart:async';

import 'package:l/l.dart';
import 'package:starter/src/_core/config.dart';

abstract interface class AnalyticsTracker {
  /// Name of the analytics tracker.
  String get name;

  /// Sets the user ID for tracking.
  Future<void> setUserId(String? userId);

  /// Sets a user property to a given value.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  });

  /// Logs the page_view event.
  Future<void> logPageView(String page, {Map<String, String>? parameters});

  /// Tracks an event with given category, name, and parameters.
  Future<void> logEvent(
    String category,
    String name, {
    Map<String, String>? parameters,
  });

  /// Sets the applicable end user consent state.
  /// By default, no consent mode values are set.
  Future<void> enableConsent();

  /// Revokes the applicable end user consent state.
  /// By default, no consent mode values are set.
  Future<void> disableConsent();
}

final class Analytics implements AnalyticsTracker {
  Analytics._({required Iterable<AnalyticsTracker> trackers})
    : _trackers = trackers;

  static final Analytics instance = Analytics._(
    trackers: switch (Config.environment) {
      EnvironmentFlavor.production => [
        // TODO(koutja): Add analytics trackers for production environment.
      ],
      EnvironmentFlavor.staging => [
        // TODO(koutja): Add analytics trackers for staging environment.
      ],
      EnvironmentFlavor.development => [
        // TODO(koutja): Add analytics trackers for development environment.
      ],
    },
  );

  @override
  String get name => 'Analytics';

  final Iterable<AnalyticsTracker> _trackers;

  @override
  Future<void> setUserId(String? userId) async {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.setUserId(userId);
      } on Object catch (e, st) {
        l.w('Error tracking set user in ${tracker.name}: $e', st);
      }
    }

    await Future.wait(_trackers.map(fn));
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.setUserProperty(name: name, value: value);
      } on Object catch (e, st) {
        l.w('Error tracking user property in ${tracker.name}: $e', st);
      }
    }

    await Future.wait(_trackers.map(fn));
  }

  @override
  Future<void> logPageView(
    String page, {
    Map<String, String>? parameters,
  }) async {
    if (page.isEmpty) {
      l.d('Page must not be empty for tracking page views');
      return;
    }
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.logPageView(page, parameters: parameters);
      } on Object catch (e, st) {
        l.w('Error tracking page view in ${tracker.name}: $e', st);
      }
    }

    await Future.wait(_trackers.map(fn));
  }

  @override
  Future<void> logEvent(
    String category,
    String name, {
    Map<String, String>? parameters,
  }) async {
    if (category.isEmpty || name.isEmpty) {
      l.d('Category or name must not be empty for tracking events');
      return;
    }
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.logEvent(category, name, parameters: parameters);
      } on Object catch (e, st) {
        l.w('Error tracking event in ${tracker.name}: $e', st);
      }
    }

    await Future.wait(_trackers.map(fn));
  }

  @override
  Future<void> enableConsent() async {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.enableConsent();
      } on Object catch (e, st) {
        l.w('Error enabling consent in ${tracker.name}: $e', st);
      }
    }

    await Future.wait(_trackers.map(fn));
  }

  @override
  Future<void> disableConsent() async {
    Future<void> fn(AnalyticsTracker tracker) async {
      try {
        await tracker.disableConsent();
      } on Object catch (e, st) {
        l.w('Error disabling consent in ${tracker.name}: $e', st);
      }
    }

    await Future.wait(_trackers.map(fn));
  }
}

class AnalyticsTracker$Logger implements AnalyticsTracker {
  @override
  String get name => 'Logger';

  @override
  Future<void> setUserId(String? userId) async {
    l.d('Analytics | UserId | $userId');
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    l.d('Analytics | Property | $name=$value');
  }

  @override
  Future<void> logPageView(
    String page, {
    Map<String, String>? parameters,
  }) async {
    l.d('Analytics | PageView | $page, $parameters');
  }

  @override
  Future<void> logEvent(
    String category,
    String name, {
    Map<String, String>? parameters,
  }) async {
    l.d('Analytics | Event | $category/$name, $parameters');
  }

  @override
  Future<void> enableConsent() async {
    l.d('Analytics | enableConsent');
  }

  @override
  Future<void> disableConsent() async {
    l.d('Analytics | disableConsent');
  }
}
