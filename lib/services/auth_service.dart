import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '919109658740-8mundtc8a6h1t86j5r1ag64cfmbmk4it.apps.googleusercontent.com'
        : null,
  );

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  // Sign in anonymously (Guest)
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  // Helper to get Google Credential
  Future<AuthCredential?> _getGoogleCredential() async {
    // 1. Trigger Google Sign In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled

    // 2. Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3. Create a new credential
    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final credential = await _getGoogleCredential();
      if (credential == null) return null;

      // 4. Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Generic Re-authentication
  Future<void> reauthenticate({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    bool reauthenticated = false;

    for (final info in user.providerData) {
      if (info.providerId == 'google.com') {
        try {
          final credential = await _getGoogleCredential();
          if (credential != null) {
            await user.reauthenticateWithCredential(credential);
            reauthenticated = true;
            break;
          } else {
            throw Exception('Google re-authentication cancelled');
          }
        } catch (e) {
          debugPrint('Error re-authenticating with Google: $e');
          rethrow;
        }
      } else if (info.providerId == 'password' && password != null) {
        await reauthenticateWithEmail(user.email!, password);
        reauthenticated = true;
        break;
      }
    }

    if (!reauthenticated) {
      // If we are anonymous or no provider matched (e.g. password user but no password provided)
      if (user.isAnonymous) return; // Anonymous users don't need strict re-auth
      if (password == null &&
          user.providerData.any((p) => p.providerId == 'password')) {
        throw Exception('Password required for re-authentication');
      }
      // If we truly failed to find a way
      if (!reauthenticated && !user.isAnonymous) {
        // Fallback?
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Ensure Firebase sign out happens even if Google fails
      await _auth.signOut();
    }
  }

  // Reload user (useful for verifying email, etc.)
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  // Delete account (Auth only)
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint('Error deleting auth account: $e');
      rethrow;
    }
  }

  // Re-authenticate with Email/Password
  Future<void> reauthenticateWithEmail(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await user.reauthenticateWithCredential(credential);
    } catch (e) {
      debugPrint('Error re-authenticating: $e');
      rethrow;
    }
  }

  // Update Email
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      await user.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      debugPrint('Error updating email: $e');
      rethrow;
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');
      await user.updatePassword(newPassword);
    } catch (e) {
      debugPrint('Error updating password: $e');
      rethrow;
    }
  }

  // Send Email Verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      debugPrint('Error sending verification email: $e');
      rethrow;
    }
  }
}
