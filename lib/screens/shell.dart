import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app.dart';
import '../data/emotions.dart';
import '../widgets/common.dart';
import 'analysis_screens.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  @override
  void initState() {
    super.initState();
    appState.loadAvatar();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: appState,
        builder: (_, __) => Scaffold(
          body: [HomeScreen(), HistoryScreen(), SettingsScreen()][_i],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _i,
            onDestinationSelected: (v) => setState(() => _i = v),
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('Home', 'ہوم')),
              NavigationDestination(icon: const Icon(Icons.history), label: tr('History', 'تاریخ')),
              NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: tr('Settings', 'ترتیبات')),
            ],
          ),
        ),
      );
}

final draft = TextEditingController();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final full = appState.firebaseReady ? FirebaseAuth.instance.currentUser?.displayName : null;
    final name = full?.split(' ').first;
    final loggedIn = appState.firebaseReady && !appState.guest && FirebaseAuth.instance.currentUser != null;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${tr('Assalam-o-Alaikum', 'السلام علیکم')}${name != null ? ', $name' : ''} 👋', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              const Text('Ehsaas AI', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ]),
          ),
          loggedIn ? UserAvatar(bytes: appState.avatar, name: full ?? 'U', size: 44) : const AppLogo(size: 44),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(gradient: kGradient, borderRadius: BorderRadius.circular(22)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('What is the emotion behind the words?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            SizedBox(height: 4),
            Text('Write an Urdu sentence and see one of 7 emotions (demo results).', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ]),
        ),
        SoftCard(
          child: Column(children: [
            TextField(
              controller: draft,
              maxLength: 280,
              maxLines: 5,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: urduStyle(19),
              decoration: InputDecoration(border: InputBorder.none, filled: false, counterText: '', hintText: 'یہاں اپنا اردو جملہ لکھیں...', hintTextDirection: TextDirection.rtl, hintStyle: urduStyle(16, color: cs.onSurfaceVariant)),
            ),
            ListenableBuilder(
              listenable: draft,
              builder: (_, __) => Align(alignment: Alignment.centerLeft, child: Text('${draft.text.length} / 280', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600))),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: draft.clear, icon: const Icon(Icons.close, size: 18), label: const Text('Clear'))),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GradientButton(
                  label: 'Analyze Emotion',
                  icon: Icons.auto_awesome,
                  onTap: () {
                    final t = draft.text.trim();
                    if (t.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an Urdu sentence')));
                      return;
                    }
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProcessingScreen(text: t)));
                  },
                ),
              ),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(children: [
            const Expanded(child: Text('Try a sample sentence', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
            TextButton.icon(onPressed: () => draft.text = (List.of(samples)..shuffle()).first.$2, icon: const Text('🎲'), label: const Text('Surprise me')),
          ]),
        ),
        for (final s in samples)
          SoftCard(
            onTap: () => draft.text = s.$2,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: emo(s.$1).color, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(s.$2, textDirection: TextDirection.rtl, style: urduStyle(14))),
            ]),
          ),
      ]),
    );
  }
}
