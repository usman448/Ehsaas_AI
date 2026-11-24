import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app.dart';
import '../services/auth_service.dart';
import '../widgets/common.dart';
import 'auth_screens.dart';
import 'shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const Gate(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ));
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: kGradient),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                child: const RobotLogo(size: 130),
              ),
              const SizedBox(height: 18),
              const Text('Ehsaas AI', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Understand Emotions in Urdu', style: TextStyle(color: Colors.white70, fontSize: 15)),
              Text('احساس', style: urduStyle(24, color: Colors.white)),
              const SizedBox(height: 24),
              SizedBox(
                width: 150,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: LinearProgressIndicator(value: _c.value, minHeight: 5, color: Colors.white, backgroundColor: Colors.white30),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
}

/// Decides which screen to show: setup help, login, or the app.
class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  Stream<User?>? _auth;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: appState,
        builder: (_, __) {
          if (!appState.firebaseReady) {
            return appState.guest ? const Shell() : const SetupScreen();
          }
          _auth ??= AuthService().changes; // stream sirf ek baar banti hai
          return StreamBuilder<User?>(
            stream: _auth,
            initialData: FirebaseAuth.instance.currentUser,
            builder: (c, s) => ((s.data?.emailVerified ?? false) || appState.guest)
                ? const Shell()
                : const LoginScreen(),
          );
        },
      );
}
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const Text('Firebase is not configured yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Open a terminal in the project folder and run:'),
            const SizedBox(height: 8),
            const SelectableText('dart pub global activate flutterfire_cli\nflutterfire configure\nflutter run'),
            const SizedBox(height: 16),
            const Text('See README.md for the full step-by-step guide.'),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => appState.setGuest(true),
              child: const Text('Preview UI as guest (no Firebase)'),
            ),
          ]),
        ),
      );
}
