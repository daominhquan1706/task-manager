import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> setPersistence({required bool rememberMe}) async {
    if (!kIsWeb) {
      return;
    }
    await _auth.setPersistence(
      rememberMe ? Persistence.LOCAL : Persistence.SESSION,
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await setPersistence(rememberMe: rememberMe);
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required bool rememberMe,
  }) async {
    await setPersistence(rememberMe: rememberMe);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signInWithGoogle({required bool rememberMe}) async {
    await setPersistence(rememberMe: rememberMe);

    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    if (kIsWeb) {
      await _auth.signInWithPopup(provider);
      return;
    }

    await _auth.signInWithProvider(provider);
  }

  Future<void> signOut() => _auth.signOut();
}
