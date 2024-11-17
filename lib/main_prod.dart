import 'package:flutter/material.dart';
import 'config/flavor_config.dart';
import 'config/environment_config.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flavor configuration
  FlavorConfig(
    flavor: Flavor.prod,
    platform: Platform.android, // Change for different platforms
    apiBaseUrl: EnvironmentConfig.prodApiUrl,
    appName: EnvironmentConfig.prodAppName,
    bundleId: EnvironmentConfig.prodAndroidId,
    shouldCollectCrashLog: true,
  ); // Don't log configuration in production

  runApp(const App());
}
