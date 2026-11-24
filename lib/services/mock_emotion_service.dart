import '../data/emotions.dart';
import '../models/analysis.dart';

/// DEMO ONLY. Replace this class with a real AI service later
/// (keep the same `predict` signature so the UI does not change).
class MockEmotionService {
  static const _kw = {
    'happiness': ['خوش', 'مبارک', 'شکر'],
    'sadness': ['اداس', 'غم', 'رو', 'دکھ', 'سونا'],
    'anger': ['غصہ', 'جھوٹ'],
    'fear': ['ڈر', 'خوف', 'گھبر'],
    'surprise': ['واہ', 'حیران', 'یقین ہی'],
    'disgust': ['گھن', 'گندگی', 'کراہت'],
  };

  Analysis predict(String text) {
    var k = 'neutral';
    final m = samples.where((s) => s.$2 == text);
    if (m.isNotEmpty) {
      k = m.first.$1;
    } else {
      for (final e in _kw.entries) {
        if (e.value.any((w) => text.contains(w))) {
          k = e.key;
          break;
        }
      }
    }
    final seed = text.codeUnits.fold<int>(0, (a, c) => a + c);
    final top = 76 + (seed % 19);
    final rest = emotions.where((e) => e.key != k).toList();
    final w = [for (var i = 0; i < rest.length; i++) 1 + ((seed * (i + 3) * 7) % 10)];
    final sum = w.reduce((a, b) => a + b);
    final d = <String, double>{
      for (var i = 0; i < rest.length; i++) rest[i].key: (100 - top) * w[i] / sum,
      k: top.toDouble(),
    };
    return Analysis(text: text, emotion: k, confidence: top.toDouble(), dist: d);
  }
}
