// File generated for DB PDF Tools Firebase configuration
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for DB PDF Tools across Android, Web, iOS, macOS, Windows.
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
        return windows;
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForDbPdfToolsWeb2026',
    appId: '1:102938475612:web:a1b2c3d4e5f6g7h8i9j0k1',
    messagingSenderId: '102938475612',
    projectId: 'db-pdf-tools',
    authDomain: 'db-pdf-tools.firebaseapp.com',
    storageBucket: 'db-pdf-tools.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForDbPdfToolsAndroid2026',
    appId: '1:102938475612:android:k1j0i9h8g7f6e5d4c3b2a1',
    messagingSenderId: '102938475612',
    projectId: 'db-pdf-tools',
    storageBucket: 'db-pdf-tools.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForDbPdfToolsIos2026',
    appId: '1:102938475612:ios:b2c3d4e5f6g7h8i9j0k1a1',
    messagingSenderId: '102938475612',
    projectId: 'db-pdf-tools',
    storageBucket: 'db-pdf-tools.appspot.com',
    iosBundleId: 'com.example.dbPdfTools',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
}
