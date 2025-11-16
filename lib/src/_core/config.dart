/// Config for app.
abstract final class Config {
  // --- ENVIRONMENT --- //

  /// Environment flavor.
  /// e.g. development, staging, production
  static final environment = EnvironmentFlavor.from(
    const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development'),
  );

  // --- API --- //

  /// Base url for api.
  /// e.g. https://api.vexus.io
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.domain.tld',
  );

  static bool get isUrlFromLocaleStorage =>
      !Config.environment.isProduction &&
      const bool.fromEnvironment('URL_FROM_LOCAL_STORAGE', defaultValue: true);

  /// Timeout in milliseconds for opening url.
  static const apiConnectTimeout = Duration(
    milliseconds: int.fromEnvironment(
      'API_CONNECT_TIMEOUT',
      defaultValue: 15000,
    ),
  );

  /// Timeout in milliseconds for receiving data from url.
  static const apiReceiveTimeout = Duration(
    milliseconds: int.fromEnvironment(
      'API_RECEIVE_TIMEOUT',
      defaultValue: 10000,
    ),
  );

  /// Cache lifetime.
  /// Refetch data from url when cache is expired.
  /// e.g. 1 hour
  static const cacheLifetime = Duration(hours: 1);

  // --- DATABASE --- //

  /// Whether to drop database on start.
  /// e.g. true
  static const dropDatabase = bool.fromEnvironment(
    'DROP_DATABASE',
  );

  /// Database file name by default.
  /// e.g. sqlite means "sqlite.db" for native platforms
  /// and "sqlite" for web platform.
  static const databaseName = String.fromEnvironment(
    'DATABASE_NAME',
    defaultValue: 'sqlite',
  );

  // --- AUTHENTICATION --- //

  /// Minimum length of password.
  /// e.g. 8
  static const passwordMinLength = int.fromEnvironment(
    'PASSWORD_MIN_LENGTH',
    defaultValue: 8,
  );

  /// Maximum length of password.
  /// e.g. 32
  static const passwordMaxLength = int.fromEnvironment(
    'PASSWORD_MAX_LENGTH',
    defaultValue: 32,
  );

  // --- LAYOUT --- //

  /// Maximum screen layout width for screen with list view.
  static const maxScreenLayoutWidth = int.fromEnvironment(
    'MAX_LAYOUT_WIDTH',
    defaultValue: 768,
  );

  static const fake = bool.fromEnvironment('FAKE');
}

/// Environment flavor.
/// e.g. development, staging, production
enum EnvironmentFlavor {
  /// Development
  development('development'),

  /// Staging
  staging('staging'),

  /// Production
  production('production')
  ;

  const EnvironmentFlavor(this.value);

  factory EnvironmentFlavor.from(String? value) => switch (value
      ?.trim()
      .toLowerCase()) {
    'development' || 'debug' || 'develop' || 'dev' => development,
    'staging' || 'profile' || 'stage' || 'stg' => staging,
    'production' || 'release' || 'prod' || 'prd' => production,
    _ =>
      const bool.fromEnvironment('dart.vm.product') ? production : development,
  };

  /// development, staging, production
  final String value;

  /// Whether the environment is development.
  bool get isDevelopment => this == development;

  /// Whether the environment is staging.
  bool get isStaging => this == staging;

  /// Whether the environment is production.
  bool get isProduction => this == production;
}
