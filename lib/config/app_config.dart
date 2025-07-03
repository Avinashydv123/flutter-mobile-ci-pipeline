enum Environment { development, qa, staging, production }

class AppConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.qa:
        return 'QA';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'Hindus R Us Dev';
      case Environment.qa:
        return 'Hindus R Us QA';
      case Environment.staging:
        return 'Hindus R Us Stage';
      case Environment.production:
        return 'Hindus R Us';
    }
  }

  static String get bundleId {
    switch (_environment) {
      case Environment.development:
        return 'com.hindusrus.app.dev';
      case Environment.qa:
        return 'com.hindusrus.app.qa';
      case Environment.staging:
        return 'com.hindusrus.app.stage';
      case Environment.production:
        return 'com.hindusrus.app';
    }
  }

  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'hindus-r-us-dev';
      case Environment.qa:
        return 'hindus-r-us-qa';
      case Environment.staging:
        return 'hindus-r-us-stage';
      case Environment.production:
        return 'hindus-r-us';
    }
  }

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static bool get isProduction => _environment == Environment.production;
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isQA => _environment == Environment.qa;
  static bool get isStaging => _environment == Environment.staging;
}
