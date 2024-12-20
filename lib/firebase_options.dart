// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyAAYUzqlT6uTg6YzqrqQiYpEEAAUe05Dck',
    appId: '1:78895844850:web:51a8d10dd2170a2d4aaf6b',
    messagingSenderId: '78895844850',
    projectId: 'emailservice-cab9d',
    authDomain: 'emailservice-cab9d.firebaseapp.com',
    databaseURL: 'https://emailservice-cab9d-default-rtdb.firebaseio.com',
    storageBucket: 'emailservice-cab9d.firebasestorage.app',
    measurementId: 'G-SP0EV7RVZK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHq5Hn3vMopxzWYUMQ-3YwBxL9uVw7cqg',
    appId: '1:78895844850:android:30640c6b60cd85724aaf6b',
    messagingSenderId: '78895844850',
    projectId: 'emailservice-cab9d',
    databaseURL: 'https://emailservice-cab9d-default-rtdb.firebaseio.com',
    storageBucket: 'emailservice-cab9d.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAAYUzqlT6uTg6YzqrqQiYpEEAAUe05Dck',
    appId: '1:78895844850:web:1422c605684d524a4aaf6b',
    messagingSenderId: '78895844850',
    projectId: 'emailservice-cab9d',
    authDomain: 'emailservice-cab9d.firebaseapp.com',
    databaseURL: 'https://emailservice-cab9d-default-rtdb.firebaseio.com',
    storageBucket: 'emailservice-cab9d.firebasestorage.app',
    measurementId: 'G-TD5FS91B8P',
  );
}
