import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static String get apiKey => _getEnv('FIREBASE_API_KEY');
  static String get appId => _getEnv('FIREBASE_APP_ID');
  static String get messagingSenderId => _getEnv('FIREBASE_MESSAGING_SENDER_ID');
  static String get projectId => _getEnv('FIREBASE_PROJECT_ID');
  static String get authDomain => _getEnv('FIREBASE_AUTH_DOMAIN');
  static String get storageBucket => _getEnv('FIREBASE_STORAGE_BUCKET');
  static String get measurementId => _getEnv('FIREBASE_MEASUREMENT_ID');

  static String _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('$key not found in .env file');
    }
    return value;
  }

  static bool get isConfigured {
    try {
      return apiKey.isNotEmpty &&
          appId.isNotEmpty &&
          projectId.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}