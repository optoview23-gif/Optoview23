// lib/firebase_options.dart
// TODO: Run `flutterfire configure --project=otica-yuri` and replace this file with the generated output.
// See: https://firebase.google.com/docs/flutter/setup
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not configured for this platform.');
    }
  }

  // TODO: Replace with values from google-services.json after running flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'otica-yuri',
    storageBucket: 'otica-yuri.appspot.com',
  );
}
