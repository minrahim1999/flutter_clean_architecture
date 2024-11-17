import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env.production");

  // Initialize app configuration
  AppConfig.init(
    appName: 'Example App',
    baseUrl: dotenv.env['API_URL'] ?? 'https://api.example.com',
    environment: Environment.production,
    shouldCollectCrashLog: true,
    themeMode: ThemeMode.system,
    enableLogging: false,
  );

  runApp(const App());
}
