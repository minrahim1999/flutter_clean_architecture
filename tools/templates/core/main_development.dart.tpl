import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env.development");

  // Initialize app configuration
  AppConfig.init(
    appName: 'Example App Dev',
    baseUrl: dotenv.env['API_URL'] ?? 'http://localhost:8080',
    environment: Environment.development,
    shouldCollectCrashLog: true,
    themeMode: ThemeMode.system,
    enableLogging: true,
  );

  runApp(const App());
}
