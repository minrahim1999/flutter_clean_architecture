import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get apiBaseUrl => 
    dotenv.env['API_BASE_URL'] ?? 'https://api.example.com/v1';

  static String get apiKey =>
    dotenv.env['API_KEY'] ?? '';

  static Duration get connectTimeout =>
    Duration(seconds: int.parse(dotenv.env['CONNECT_TIMEOUT'] ?? '5'));

  static Duration get receiveTimeout =>
    Duration(seconds: int.parse(dotenv.env['RECEIVE_TIMEOUT'] ?? '3'));

  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
  };

  static bool get isProduction =>
    dotenv.env['ENVIRONMENT']?.toLowerCase() == 'production';

  static String get dbName =>
    dotenv.env['DB_NAME'] ?? 'newsletter.db';

  static String get cacheDir {
    if (Platform.isWindows) {
      return dotenv.env['CACHE_DIR_WINDOWS'] ?? 'C:\\ProgramData\\newsletter';
    } else if (Platform.isMacOS) {
      return dotenv.env['CACHE_DIR_MACOS'] ?? '/Library/Caches/newsletter';
    } else {
      return dotenv.env['CACHE_DIR_LINUX'] ?? '/var/cache/newsletter';
    }
  }
}
