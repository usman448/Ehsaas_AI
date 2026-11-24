import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../app.dart';
import '../data/emotions.dart';
import '../models/analysis.dart';
import '../services/firestore_service.dart';
import '../widgets/common.dart';
import 'analysis_screens.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistState();
}

class _HistState extends State<HistoryScreen> {
  List<Analysis> _items = [];
  bool _loading = true;
  String? _err;
  String _q = '';

  bool get _canUse => !appState.guest && appState.firebaseReady && FirebaseAuth.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_canUse) {
      setState(() => _loading = false);
      return;
    }
    setState(() { _loading = true; _err = null; });
    try {
      _items = await FirestoreService().load();
    } catch (_) {
      _err = 'Could not load history. Check your connection and Firestore setup.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All saved analyses will be deleted.'),
        actions: [TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Clear'))],
      ),
    );
    if (ok == true) {
      await FirestoreService().clear();
      _load();
    }
  }

  Widget _insights() {
    final c = <String, int>{};
    for (final a in _items) {
      c[a.emotion] = (c[a.emotion] ?? 0) + 1;
    }
    final top = c.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final e = emo(top.key);
    return SoftCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(e.emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mood insights', style: TextStyle(fontWeight: FontWeight.w700)),
              Text('Mostly ${e.en} · ${top.value} of ${_items.length} analyses', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(height: 10, child: Row(children: [for (final x in c.entries) Expanded(flex: x.value, child: Container(color: emo(x.key).color))])),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 4, children: [for (final x in c.entries) Text('${emo(x.key).emoji} ${x.value}', style: const TextStyle(fontSize: 12))]),
      ]),
    );
  }

  Widget _msg(String emoji, String title, String sub) => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
        const SizedBox(height: 60),
        Center(child: Text(emoji, style: const TextStyle(fontSize: 54))),
        Center(child: Padding(padding: const EdgeInsets.only(top: 10), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)))),
        Padding(padding: const EdgeInsets.all(12), child: Text(sub, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
      ]);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final list = _items.where((a) => a.text.contains(_q) || a.emotion.contains(_q.toLowerCase())).toList();
    Widget body;
    if (!_canUse) {
      body = _msg('🔒', 'Login to see your history', 'Guests cannot save analyses. Sign up to keep your history.');
    } else if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_err != null) {
      body = _msg('⚠️', 'Something went wrong', _err!);
    } else if (list.isEmpty) {
      body = _msg('🗂️', _items.isEmpty ? 'No analyses yet' : 'No matches found', _items.isEmpty ? 'Your saved sentences will appear here.' : 'Try a different search.');
    } else {
      body = ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
        if (_q.isEmpty) _insights(),
        for (final a in list)
          SoftCard(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(a: a, saved: true))),
            child: Column(children: [
              SizedBox(width: double.infinity, child: Text(a.text, maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: urduStyle(15))),
              Row(children: [
                EmotionBadge(a.emotion),
                const SizedBox(width: 8),
                Expanded(child: Text('${a.confidence.round()}% · ${a.createdAt != null ? DateFormat('d MMM, h:mm a').format(a.createdAt!) : 'just now'}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12))),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () async {
                    await FirestoreService().delete(a.id!);
                    setState(() => _items.removeWhere((x) => x.id == a.id));
                  },
                ),
              ]),
            ]),
          ),
      ]);
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text(tr('History', 'تاریخ'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
            if (_canUse && _items.isNotEmpty) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearAll),
          ]),
          const SizedBox(height: 10),
          TextField(decoration: const InputDecoration(hintText: 'Search history...', prefixIcon: Icon(Icons.search)), onChanged: (v) => setState(() => _q = v)),
          const SizedBox(height: 14),
          Expanded(child: RefreshIndicator(onRefresh: _load, child: body)),
        ]),
      ),
    );
  }
}
