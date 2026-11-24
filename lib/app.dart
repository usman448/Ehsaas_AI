import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'widgets/common.dart';

class AppState extends ChangeNotifier {
  ThemeMode mode = ThemeMode.light;
  String lang = 'en';
  bool guest = false;
  bool firebaseReady = false;
  Uint8List? avatar;

  String get _akey => 'avatar_${firebaseReady ? (FirebaseAuth.instance.currentUser?.uid ?? 'guest') : 'guest'}';

  Future<void> loadAvatar() async {
    final s = (await SharedPreferences.getInstance()).getString(_akey);
    avatar = s == null ? null : base64Decode(s);
    notifyListeners();
  }

  Future<void> setAvatar(Uint8List? b) async {
    avatar = b;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    b == null ? await p.remove(_akey) : await p.setString(_akey, base64Encode(b));
  }

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    mode = p.getBool('dark') == true ? ThemeMode.dark : ThemeMode.light;
    lang = p.getString('lang') ?? 'en';
  }

  Future<void> setDark(bool d) async {
    mode = d ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    (await SharedPreferences.getInstance()).setBool('dark', d);
  }

  Future<void> setLang(String l) async {
    lang = l;
    notifyListeners();
    (await SharedPreferences.getInstance()).setString('lang', l);
  }

  void setGuest(bool g) {
    guest = g;
    notifyListeners();
  }
}

final appState = AppState();
String tr(String en, String ur) => appState.lang == 'ur' ? ur : en;

ThemeData buildTheme(Brightness b) {
  final d = b == Brightness.dark;
  final card = d ? const Color(0xFF1A1E3A) : Colors.white;
  final line = d ? const Color(0xFF2A2F55) : const Color(0xFFE6E9F6);
  final cs = ColorScheme.fromSeed(seedColor: kPurple, brightness: b).copyWith(
    surface: card,
    outlineVariant: line,
    onSurface: d ? const Color(0xFFEEF0FF) : const Color(0xFF1B2250),
    onSurfaceVariant: d ? const Color(0xFF9AA0C8) : const Color(0xFF6B7299),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor: d ? const Color(0xFF0F1226) : const Color(0xFFF4F6FD),
    textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: b).textTheme)
        .apply(bodyColor: cs.onSurface, displayColor: cs.onSurface),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: line),
      ),
    ),
  );
}

class EhsaasApp extends StatelessWidget {
  const EhsaasApp({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: appState,
        builder: (_, __) => MaterialApp(
          title: 'Ehsaas AI',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: appState.mode,
          home: const SplashScreen(),
        ),
      );
}
