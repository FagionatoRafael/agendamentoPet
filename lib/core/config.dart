import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static String get apiKey => _getEnv('FIREBASE_API_KEY');
  static String get appId => _getEnv('FIREBASE_APP_ID');
  static String get messagingSenderId =>
      _getEnv('FIREBASE_MESSAGING_SENDER_ID');
  static String get projectId => _getEnv('FIREBASE_PROJECT_ID');
  static String get authDomain => _getEnv('FIREBASE_AUTH_DOMAIN');
  static String get storageBucket => _getEnv('FIREBASE_STORAGE_BUCKET');
  static String get measurementId => _getEnv('FIREBASE_MEASUREMENT_ID');

  static String get apiKeyWeb => _getEnv('FIREBASE_API_KEY_WEB');
  static String get appIdWeb => _getEnv('FIREBASE_APP_ID_WEB');
  static String get messagingSenderIdWeb =>
      _getEnv('FIREBASE_MESSAGING_SENDER_ID_WEB');
  static String get projectIdWeb => _getEnv('FIREBASE_PROJECT_ID_WEB');
  static String get authDomainWeb => _getEnv('FIREBASE_AUTH_DOMAIN_WEB');
  static String get storageBucketWeb => _getEnv('FIREBASE_STORAGE_BUCKET_WEB');
  static String get measurementIdWeb => _getEnv('FIREBASE_MEASUREMENT_ID_web');

  static String _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception('$key not found in .env file');
    }
    return value;
  }

  static bool get isConfigured {
    try {
      return apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
