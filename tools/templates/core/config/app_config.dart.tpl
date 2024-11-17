import 'package:flutter/material.dart';

enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  final String appName;
  final String baseUrl;
  final Environment environment;
  final bool shouldCollectCrashLog;
  final ThemeMode themeMode;
  final bool enableLogging;

  static late AppConfig _instance;

  AppConfig._({
    required this.appName,
    required this.baseUrl,
    required this.environment,
    required this.shouldCollectCrashLog,
    required this.themeMode,
    required this.enableLogging,
  });

  static AppConfig get instance => _instance;

  static void init({
    required String appName,
    required String baseUrl,
    required Environment environment,
    bool shouldCollectCrashLog = true,
    ThemeMode themeMode = ThemeMode.system,
    bool enableLogging = true,
  }) {
    _instance = AppConfig._(
      appName: appName,
      baseUrl: baseUrl,
      environment: environment,
      shouldCollectCrashLog: shouldCollectCrashLog,
      themeMode: themeMode,
      enableLogging: enableLogging,
    );
  }

  static bool get isProduction => _instance.environment == Environment.production;
  static bool get isStaging => _instance.environment == Environment.staging;
  static bool get isDevelopment => _instance.environment == Environment.development;
}
