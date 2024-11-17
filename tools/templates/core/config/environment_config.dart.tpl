import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static bool get enableLogging => dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  static int get cacheDuration => int.tryParse(dotenv.env['CACHE_DURATION'] ?? '3600') ?? 3600;

  // Add more environment-specific configurations as needed
  static Map<String, dynamic> toMap() => {
        'apiUrl': apiUrl,
        'apiKey': apiKey,
        'enableLogging': enableLogging,
        'cacheDuration': cacheDuration,
      };
}
