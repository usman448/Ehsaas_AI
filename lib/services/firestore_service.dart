import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/analysis.dart';

class FirestoreService {
  // Path is always users/{currentUid}/analyses, so a user only touches their own data.
  CollectionReference<Map<String, dynamic>> get _col => FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('analyses');

  Future<void> save(Analysis a) => _col.add(a.toMap());

  Future<List<Analysis>> load() async {
    final s = await _col.orderBy('createdAt', descending: true).get();
    return s.docs.map(Analysis.fromDoc).toList();
  }

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> clear() async {
    final s = await _col.get();
    for (var i = 0; i < s.docs.length; i += 400) {
      final b = FirebaseFirestore.instance.batch();
      for (final d in s.docs.skip(i).take(400)) {
        b.delete(d.reference);
      }
      await b.commit();
    }
  }
}
