import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailNotVerified implements Exception {
  const EmailNotVerified();
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get changes => _auth.authStateChanges();

  /// Logs in, but only lets verified emails in. No email is sent from here.
  Future<void> login(String email, String password) async {
    final c = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (!c.user!.emailVerified) {
      await _auth.signOut();
      throw const EmailNotVerified();
    }
  }

  Future<void> signUp(String name, String email, String password, String role) async {
    final c = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final u = c.user!;
    await u.updateDisplayName(name);
    await u.sendEmailVerification();
    try {
      await _db.collection('users').doc(u.uid).set({
        'uid': u.uid,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Profile can be saved later if Firestore rules are not published yet.
    }
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email);

  Future<Map<String, dynamic>?> profile() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return (await _db.collection('users').doc(u.uid).get()).data();
  }

  Future<void> logout() => _auth.signOut();

  static String friendly(Object e) {
    if (e is EmailNotVerified) {
      return 'Your email is not verified yet. Please open the verification link we sent when you signed up.';
    }
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'network-request-failed':
          return 'No internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'user-disabled':
          return 'This account has been disabled.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}