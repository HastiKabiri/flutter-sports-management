import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to track login status
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 1. Email & Password Sign Up
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Sign Up Error: ${e.message}");
      return null;
    }
  }

  // 2. Email & Password Sign In
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print("Sign In Error: ${e.message}");
      return null;
    }
  }

  // 3. Anonymous Sign In
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print("Anonymous Auth Error: $e");
      return null;
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

