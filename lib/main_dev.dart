import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'config/environment_config.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor configuration
  FlavorConfig(
    flavor: Flavor.dev,
    platform: Platform.android, // Change for different platforms
    apiBaseUrl: EnvironmentConfig.devApiUrl,
    appName: EnvironmentConfig.devAppName,
    bundleId: EnvironmentConfig.devAndroidId,
    shouldCollectCrashLog: true,
  ).logConfig(); // Log configuration in debug mode

  runApp(const App());
}
