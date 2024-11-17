class EnvironmentConfig {
  // Android Bundle IDs
  static const devAndroidId = 'com.example.newsletter.dev';
  static const stagingAndroidId = 'com.example.newsletter.staging';
  static const prodAndroidId = 'com.example.newsletter';

  // Huawei Bundle IDs
  static const devHuaweiId = 'com.example.newsletter.huawei.dev';
  static const stagingHuaweiId = 'com.example.newsletter.huawei.staging';
  static const prodHuaweiId = 'com.example.newsletter.huawei';

  // iOS Bundle IDs
  static const devIosId = 'com.example.newsletter.dev';
  static const stagingIosId = 'com.example.newsletter.staging';
  static const prodIosId = 'com.example.newsletter';

  // App Names
  static const devAppName = 'Newsletter Dev';
  static const stagingAppName = 'Newsletter Staging';
  static const prodAppName = 'Newsletter';

  // API URLs
  static const devApiUrl = 'https://newsapi.org/v2';
  static const stagingApiUrl = 'https://newsapi.org/v2';
  static const prodApiUrl = 'https://newsapi.org/v2';

  // API Keys
  static const devApiKey = 'your_dev_api_key';
  static const stagingApiKey = 'your_staging_api_key';
  static const prodApiKey = 'your_prod_api_key';

  // Firebase Configuration
  static const devFirebaseProjectId = 'newsletter-dev';
  static const stagingFirebaseProjectId = 'newsletter-staging';
  static const prodFirebaseProjectId = 'newsletter-prod';

  // Huawei Configuration
  static const devHuaweiAppId = 'your_dev_huawei_app_id';
  static const stagingHuaweiAppId = 'your_staging_huawei_app_id';
  static const prodHuaweiAppId = 'your_prod_huawei_app_id';

  // Analytics
  static const shouldCollectAnalytics = true;
  static const shouldCollectCrashlytics = true;

  // Cache Configuration
  static const cacheValidityDuration = Duration(hours: 24);
  static const maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Timeouts
  static const connectionTimeout = Duration(seconds: 30);
  static const receiveTimeout = Duration(seconds: 30);

  // Pagination
  static const defaultPageSize = 20;
  static const maxPageSize = 50;

  // Feature Flags
  static final devFeatureFlags = {
    'enablePushNotifications': true,
    'enableOfflineMode': true,
    'enableDarkMode': true,
    'enableBiometrics': true,
  };

  static final stagingFeatureFlags = {
    'enablePushNotifications': true,
    'enableOfflineMode': true,
    'enableDarkMode': true,
    'enableBiometrics': true,
  };

  static final prodFeatureFlags = {
    'enablePushNotifications': true,
    'enableOfflineMode': true,
    'enableDarkMode': true,
    'enableBiometrics': true,
  };

  // Get feature flags based on environment
  static Map<String, bool> getFeatureFlags(String environment) {
    switch (environment) {
      case 'dev':
        return devFeatureFlags;
      case 'staging':
        return stagingFeatureFlags;
      case 'prod':
        return prodFeatureFlags;
      default:
        return prodFeatureFlags;
    }
  }

  // Get API key based on environment
  static String getApiKey(String environment) {
    switch (environment) {
      case 'dev':
        return devApiKey;
      case 'staging':
        return stagingApiKey;
      case 'prod':
        return prodApiKey;
      default:
        return prodApiKey;
    }
  }

  // Get Firebase project ID based on environment
  static String getFirebaseProjectId(String environment) {
    switch (environment) {
      case 'dev':
        return devFirebaseProjectId;
      case 'staging':
        return stagingFirebaseProjectId;
      case 'prod':
        return prodFirebaseProjectId;
      default:
        return prodFirebaseProjectId;
    }
  }

  // Get Huawei App ID based on environment
  static String getHuaweiAppId(String environment) {
    switch (environment) {
      case 'dev':
        return devHuaweiAppId;
      case 'staging':
        return stagingHuaweiAppId;
      case 'prod':
        return prodHuaweiAppId;
      default:
        return prodHuaweiAppId;
    }
  }
}
