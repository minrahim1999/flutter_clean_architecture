import 'package:flutter/foundation.dart';

enum Flavor {
  dev,
  staging,
  prod,
}

enum Platform {
  android,
  huawei,
  ios,
}

class FlavorConfig {
  final Flavor flavor;
  final Platform platform;
  final String apiBaseUrl;
  final String appName;
  final String bundleId;
  final bool shouldCollectCrashLog;

  static FlavorConfig? _instance;

  factory FlavorConfig({
    required Flavor flavor,
    required Platform platform,
    required String apiBaseUrl,
    required String appName,
    required String bundleId,
    bool shouldCollectCrashLog = false,
  }) {
    _instance ??= FlavorConfig._internal(
      flavor,
      platform,
      apiBaseUrl,
      appName,
      bundleId,
      shouldCollectCrashLog,
    );
    return _instance!;
  }

  FlavorConfig._internal(
    this.flavor,
    this.platform,
    this.apiBaseUrl,
    this.appName,
    this.bundleId,
    this.shouldCollectCrashLog,
  );

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig must be initialized first');
    return _instance!;
  }

  static bool isProduction() => _instance?.flavor == Flavor.prod;
  static bool isStaging() => _instance?.flavor == Flavor.staging;
  static bool isDevelopment() => _instance?.flavor == Flavor.dev;

  static bool isAndroid() => _instance?.platform == Platform.android;
  static bool isHuawei() => _instance?.platform == Platform.huawei;
  static bool isIOS() => _instance?.platform == Platform.ios;

  static void reset() {
    _instance = null;
  }

  @override
  String toString() {
    return '''FlavorConfig(
      flavor: $flavor,
      platform: $platform,
      apiBaseUrl: $apiBaseUrl,
      appName: $appName,
      bundleId: $bundleId,
      shouldCollectCrashLog: $shouldCollectCrashLog
    )''';
  }

  void logConfig() {
    if (kDebugMode) {
      print(toString());
    }
  }
}
