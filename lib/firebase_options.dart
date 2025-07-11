// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBRSPGjBpz7_Ac-l2zQqwVz2iU5ForIdsY',
    appId: '1:654642144013:web:ad6fc05e5d756594a94644',
    messagingSenderId: '654642144013',
    projectId: 'dynamicform-ae960',
    authDomain: 'dynamicform-ae960.firebaseapp.com',
    storageBucket: 'dynamicform-ae960.firebasestorage.app',
    measurementId: 'G-ZZZ3RKFGX6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeNIzPe_ULZCe87AS28nAY3nOrEGhMDro',
    appId: '1:654642144013:android:3e8214b4beb5e0d4a94644',
    messagingSenderId: '654642144013',
    projectId: 'dynamicform-ae960',
    storageBucket: 'dynamicform-ae960.firebasestorage.app',
  );
}
