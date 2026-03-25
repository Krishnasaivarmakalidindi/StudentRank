import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  // ─── Email + Password Sign In ───
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

  // ─── Email + Password Sign Up ───
  Future<User?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name
      await credential.user?.updateDisplayName(name);

      return credential.user;
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  // ─── Google Sign In (handles both sign-up and sign-in) ───
  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      final credential = await _getGoogleCredential();
      if (credential == null) {
        return GoogleSignInResult(user: null, isNewUser: false);
      }

      try {
        final userCredential = await _auth.signInWithCredential(credential);
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        return GoogleSignInResult(
          user: userCredential.user,
          isNewUser: isNewUser,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // Credential linking scenario — get email from Google account
          final googleUser = _googleSignIn.currentUser;
          final email = googleUser?.email;
          if (email != null) {
            final linked = await _linkGoogleCredential(email, credential);
            if (linked != null) {
              return GoogleSignInResult(user: linked, isNewUser: false);
            }
          }
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // ─── Credential Linking ───
  /// Links Google credential to existing email/password account
  Future<User?> _linkGoogleCredential(
      String email, AuthCredential googleCredential) async {
    try {
      // The user has an existing account with a different provider.
      // In V2, we tell the UI to prompt the user to sign in with their
      // existing password first, then link the Google credential.
      debugPrint('User has existing account for $email — prompting to link');
      throw FirebaseAuthException(
        code: 'requires-password-link',
        message:
            'This email is already registered with a password. Please sign in with your password first to link Google.',
      );
    } catch (e) {
      debugPrint('Error linking Google credential: $e');
      rethrow;
    }
  }

  /// Link Google provider to current user (called after password sign-in)
  Future<User?> linkCurrentUserWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final credential = await _getGoogleCredential();
      if (credential == null) return null;

      final result = await user.linkWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        debugPrint('Google already linked');
        return _auth.currentUser;
      }
      rethrow;
    } catch (e) {
      debugPrint('Error linking Google: $e');
      rethrow;
    }
  }

  // ─── Helper: Get Google Credential ───
  Future<AuthCredential?> _getGoogleCredential() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    return GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
  }

  // ─── Re-authentication ───
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
      if (password == null &&
          user.providerData.any((p) => p.providerId == 'password')) {
        throw Exception('Password required for re-authentication');
      }
    }
  }

  // ─── Re-authenticate with Email ───
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

  // ─── Sign Out ───
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signing out: $e');
      await _auth.signOut();
    }
  }

  // ─── Reload User ───
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  // ─── Delete Account ───
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint('Error deleting auth account: $e');
      rethrow;
    }
  }

  // ─── Send Email Verification ───
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

  // ─── Update Email ───
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

  // ─── Update Password ───
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

  // ─── Check if email is verified ───
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ─── Check if user signed in with Google ───
  bool get isGoogleUser =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'google.com') ??
      false;

  // ─── Check if user signed in with email/password ───
  bool get isPasswordUser =>
      _auth.currentUser?.providerData.any((p) => p.providerId == 'password') ??
      false;
}

/// Result of Google sign-in indicating if the user is new
class GoogleSignInResult {
  final User? user;
  final bool isNewUser;

  GoogleSignInResult({this.user, required this.isNewUser});
}

/// Custom exception for Firebase Auth
class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseAuthException($code): $message';
}
