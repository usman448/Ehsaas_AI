import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/emotions.dart';

class Analysis {
  final String? id;
  final String text, emotion;
  final double confidence;
  final Map<String, double> dist;
  final DateTime? createdAt;
  const Analysis({this.id, required this.text, required this.emotion, required this.confidence, required this.dist, this.createdAt});

  Map<String, dynamic> toMap() => {
        'text': text,
        'emotion': emotion,
        'emotionUrdu': emo(emotion).ur,
        'confidence': confidence,
        'confidenceDistribution': dist,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory Analysis.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data()!;
    return Analysis(
      id: d.id,
      text: (m['text'] ?? '') as String,
      emotion: (m['emotion'] ?? 'neutral') as String,
      confidence: ((m['confidence'] ?? 0) as num).toDouble(),
      dist: ((m['confidenceDistribution'] ?? {}) as Map).map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
