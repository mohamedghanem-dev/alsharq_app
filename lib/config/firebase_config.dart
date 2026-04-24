// Firebase configuration

import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String databaseURL = String.fromEnvironment('FIREBASE_DATABASE_URL');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String messagingSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
}