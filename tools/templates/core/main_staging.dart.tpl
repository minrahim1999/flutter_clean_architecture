import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env.staging");

  // Initialize app configuration
  AppConfig.init(
    appName: 'Example App Staging',
    baseUrl: dotenv.env['API_URL'] ?? 'https://staging.example.com',
    environment: Environment.staging,
    shouldCollectCrashLog: true,
    themeMode: ThemeMode.system,
    enableLogging: true,
  );

  runApp(const App());
}
