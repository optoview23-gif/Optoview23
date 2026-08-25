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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6383nLU2-gxS3Oial_rfW1i7E3hNsKBk',
    appId: '1:763653043562:android:8a74e83d595684c952a113',
    messagingSenderId: '763653043562',
    projectId: 'otica-yuri',
    storageBucket: 'otica-yuri.firebasestorage.app',
  );
}
