// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQW-rq_nSsiafrslOd456LBlEfiHTi9pY',
    appId: '1:644477378453:web:b4d7659b38507156dba09c',
    messagingSenderId: '644477378453',
    projectId: 'psm-app-16965',
    authDomain: 'psm-app-16965.firebaseapp.com',
    storageBucket: 'psm-app-16965.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlSpYLIeMsMqDZwWvgQAOJDy15QGBcav0',
    appId: '1:644477378453:android:ceeffd9f20639ccedba09c',
    messagingSenderId: '644477378453',
    projectId: 'psm-app-16965',
    storageBucket: 'psm-app-16965.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBA3bBAPm9eGqNmIWV5EItcbRiJJiGG--k',
    appId: '1:644477378453:ios:b85e1e2a5d49f434dba09c',
    messagingSenderId: '644477378453',
    projectId: 'psm-app-16965',
    storageBucket: 'psm-app-16965.appspot.com',
    iosBundleId: 'com.example.fypPsm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBA3bBAPm9eGqNmIWV5EItcbRiJJiGG--k',
    appId: '1:644477378453:ios:f0e5837e27d87596dba09c',
    messagingSenderId: '644477378453',
    projectId: 'psm-app-16965',
    storageBucket: 'psm-app-16965.appspot.com',
    iosBundleId: 'com.example.fypPsm.RunnerTests',
  );
}
