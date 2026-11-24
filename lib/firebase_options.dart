import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => kIsWeb ? web : android;

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyDEYrv6ksgq39pjPLBs81109wc3sXEIIFI',
    appId: '1:430388751421:android:cfaf9d80af1b800ff8ce54',
    messagingSenderId: '430388751421',
    projectId: 'ehsaas-ai',
    storageBucket: 'ehsaas-ai.firebasestorage.app',
  );

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDFQnVAAr0e-tco5dsr2t0O_Qu2KDLiKZQ',
    appId: '1:430388751421:web:b5c8c13e641477c0f8ce54',
    messagingSenderId: '430388751421',
    projectId: 'ehsaas-ai',
    authDomain: 'ehsaas-ai.firebaseapp.com',
    storageBucket: 'ehsaas-ai.firebasestorage.app',
  );
}