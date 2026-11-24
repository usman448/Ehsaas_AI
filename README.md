# Ehsaas AI (Flutter) - Urdu Emotion Detection UI

Flutter app (Android first) with Firebase Auth + Firestore history.
**Emotion results are DEMO/mock results (`lib/services/mock_emotion_service.dart`). No AI model is used yet.**

## 1. One-time installs (Windows)
1. Install Flutter: https://docs.flutter.dev/get-started/install/windows (unzip to `C:\src\flutter`, add `C:\src\flutter\bin` to PATH).
2. Install Android Studio, open it, install the Android SDK + an emulator (Device Manager).
3. Install VS Code + the "Flutter" and "Dart" extensions.
4. Check everything: `flutter doctor` (accept licenses with `flutter doctor --android-licenses`).
5. Install Node.js, then: `npm install -g firebase-tools` and `firebase login`.
6. `dart pub global activate flutterfire_cli`

## 2. Create the project and copy these files
```
flutter create ehsaas_ai
```
Then copy `lib/`, `pubspec.yaml` and `firestore.rules` from this folder into `ehsaas_ai/` (replace the existing ones).
```
cd ehsaas_ai
flutter pub get
```
(If versions clash: `flutter pub add firebase_core firebase_auth cloud_firestore shared_preferences google_fonts intl`)

## 3. Firebase setup
1. https://console.firebase.google.com -> Add project.
2. Build -> Authentication -> Get started -> enable **Email/Password**.
3. Build -> Firestore Database -> Create database.
4. In the project folder run `flutterfire configure`, pick your project and **Android**. This creates `lib/firebase_options.dart` and `android/app/google-services.json`.
5. Publish the rules: copy `firestore.rules` into Firestore -> Rules tab -> Publish (or `firebase deploy --only firestore:rules`).

## 4. Run
- Emulator: start it in Android Studio, then `flutter run`.
- Phone: enable Developer options + USB debugging, connect, `flutter devices`, `flutter run`.

## Troubleshooting
- "Firebase is not configured yet" screen -> run `flutterfire configure` again.
- Gradle error about `minSdkVersion` -> in `android/app/build.gradle(.kts)` set minSdk to 23.
- History not loading -> check Firestore is created and rules are published.

## Limits / next step
Mock predictions only. To add a real model later, replace `MockEmotionService.predict` with a service that calls your API.
