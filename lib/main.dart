import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    appState.firebaseReady = true;
  } catch (_) {
    appState.firebaseReady = false; // shows the setup screen
  }
  await appState.load();
  runApp(const EhsaasApp());
}
