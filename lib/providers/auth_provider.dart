import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = StreamProvider<User?>(
      (ref) => FirebaseAuth.instance.authStateChanges(),
);

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Shared GoogleSignIn instance (important for mobile)
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Email/password sign-in
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? "Email sign-in failed",
      );
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? "Google Sign-In failed",
      );
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
