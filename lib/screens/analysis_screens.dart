import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../data/emotions.dart';
import '../models/analysis.dart';
import '../services/firestore_service.dart';
import '../services/mock_emotion_service.dart';
import '../widgets/common.dart';
import 'shell.dart';

class ProcessingScreen extends StatefulWidget {
  final String text;
  const ProcessingScreen({super.key, required this.text});
  @override
  State<ProcessingScreen> createState() => _ProcState();
}

class _ProcState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  int _step = 0;
  Timer? _t;
  static const _steps = ['Processing Urdu Text', 'Analyzing Linguistic Patterns', 'Detecting Emotion'];

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (!mounted) return;
      setState(() => _step++);
      if (_step >= 3) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          final r = MockEmotionService().predict(widget.text); // demo result
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ResultScreen(a: r)));
        });
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, -8 * _c.value),
                child: Container(
                  width: 150,
                  height: 150,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: kGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: kPurple.withValues(alpha: .4), blurRadius: 40 + 20 * _c.value, offset: const Offset(0, 16))]),
                  child: const Text('🧠', style: TextStyle(fontSize: 56)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Analyzing your emotions...', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 22),
            SoftCard(
              child: Column(children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _step > i ? kTeal : (_step == i ? kPurple : cs.outlineVariant),
                        child: _step > i ? const Icon(Icons.check, size: 16, color: Colors.white) : Text('${i + 1}', style: TextStyle(fontSize: 12, color: _step == i ? Colors.white : cs.onSurfaceVariant)),
                      ),
                      const SizedBox(width: 12),
                      Text(_steps[i], style: TextStyle(fontWeight: FontWeight.w600, color: _step >= i ? cs.onSurface : cs.onSurfaceVariant)),
                    ]),
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  final Analysis a;
  final bool saved;
  const ResultScreen({super.key, required this.a, this.saved = false});
  @override
  State<ResultScreen> createState() => _ResState();
}

class _ResState extends State<ResultScreen> {
  late bool _saved = widget.saved;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (!widget.saved) HapticFeedback.mediumImpact();
  }

  Future<void> _save() async {
    if (appState.guest || !appState.firebaseReady || FirebaseAuth.instance.currentUser == null) {
      showDialog(
        context: context,
        builder: (d) => AlertDialog(
          title: const Text('Login required'),
          content: const Text('Please log in or sign up to save your analysis history.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pop(d);
                Navigator.of(context).popUntil((r) => r.isFirst);
                appState.setGuest(false);
              },
              child: const Text('Login / Sign Up'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await FirestoreService().save(widget.a);
      _saved = true;
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save. Check your connection and Firestore setup.')));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.a, e = emo(a.emotion), cs = Theme.of(context).colorScheme;
    final ds = a.dist.entries.toList()..sort((x, y) => y.value.compareTo(x.value));
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Result', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
          SoftCard(child: SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('YOUR SENTENCE', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
            Text(a.text, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: urduStyle(18)),
          ]))),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: e.color.withValues(alpha: .12), borderRadius: BorderRadius.circular(22), border: Border.all(color: e.color.withValues(alpha: .4))),
            child: Column(children: [
              Row(children: [
                TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 900), curve: Curves.elasticOut, builder: (_, v, child) => Transform.scale(scale: v, child: child), child: Text(e.emoji, style: const TextStyle(fontSize: 60))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PREDICTED EMOTION', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(e.en, style: TextStyle(color: e.color, fontSize: 28, fontWeight: FontWeight.w800)),
                  Text(e.ur, style: urduStyle(18)),
                ])),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(alignment: Alignment.center, children: [
                    SizedBox.expand(child: CircularProgressIndicator(value: a.confidence / 100, strokeWidth: 8, color: e.color, backgroundColor: cs.outlineVariant)),
                    Text('${a.confidence.round()}%', style: TextStyle(color: e.color, fontWeight: FontWeight.w800, fontSize: 18)),
                  ]),
                ),
              ]),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(emotion: a.emotion, confidence: a.confidence))), child: Text('Learn about ${e.en} →'))),
            ]),
          ),
          SoftCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Confidence distribution', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 12),
            for (final d in ds)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  SizedBox(width: 108, child: Text('${emo(d.key).emoji} ${emo(d.key).en}', style: TextStyle(fontSize: 13, fontWeight: d.key == a.emotion ? FontWeight.w700 : FontWeight.w500))),
                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(9), child: LinearProgressIndicator(value: d.value / 100, minHeight: 8, color: emo(d.key).color, backgroundColor: cs.outlineVariant))),
                  SizedBox(width: 48, child: Text('${d.value.toStringAsFixed(1)}%', textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant))),
                ]),
              ),
          ])),
          Text('Demo result: generated by a mock service, not by a trained AI model.', textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () { draft.clear(); Navigator.of(context).popUntil((r) => r.isFirst); }, child: const Text('↻ Analyze Another'))),
            const SizedBox(width: 10),
            Expanded(child: GradientButton(label: _saved ? '✓ Saved' : 'Save Result', loading: _busy, onTap: _saved ? null : _save)),
          ]),
        ]),
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final String emotion;
  final double? confidence;
  const DetailsScreen({super.key, required this.emotion, this.confidence});
  @override
  Widget build(BuildContext context) {
    final e = emo(emotion), cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Details', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(color: e.color.withValues(alpha: .15), borderRadius: BorderRadius.circular(22)),
            child: Column(children: [
              Text(e.emoji, style: const TextStyle(fontSize: 80)),
              Text(e.en, style: TextStyle(color: e.color, fontSize: 30, fontWeight: FontWeight.w800)),
              Text(e.ur, style: urduStyle(22)),
              if (confidence != null)
                Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(99)), child: Text('Confidence ${confidence!.round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
            ]),
          ),
          SoftCard(child: SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('DESCRIPTION', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(e.desc, style: const TextStyle(height: 1.5)),
          ]))),
          SoftCard(child: SizedBox(width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('اردو وضاحت', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
            Text(e.urDesc, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: urduStyle(15)),
          ]))),
          SoftCard(child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: e.color),
            const SizedBox(width: 12),
            const Expanded(child: Text('Theme color', style: TextStyle(fontWeight: FontWeight.w700))),
            Text(e.emoji, style: const TextStyle(fontSize: 26)),
          ])),
        ]),
      ),
    );
  }
}
