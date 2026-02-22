import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentrank/models/user.dart';
import 'package:studentrank/services/auth_service.dart';
import 'package:studentrank/services/user_service.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = true;
  bool _isCreatingProfile = false;
  bool _needsOnboarding = false;
  StreamSubscription<auth.User?>? _authSubscription;
  ThemeMode _themeMode = ThemeMode.light;

  // ─── Getters ───
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authService.currentUser != null;
  bool get needsOnboarding => _needsOnboarding;
  ThemeMode get themeMode => _themeMode;

  bool get isPasswordAuth => _authService.isPasswordUser;
  bool get isGoogleAuth => _authService.isGoogleUser;
  bool get isEmailVerified => _authService.isEmailVerified;

  AppProvider() {
    _init();
  }

  void _init() async {
    // Load saved theme
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme_mode');
      if (themeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }

    // Listen to auth state changes
    _authSubscription =
        _authService.authStateChanges.listen((auth.User? firebaseUser) async {
      if (_isCreatingProfile) return;

      if (firebaseUser == null) {
        _currentUser = null;
        _needsOnboarding = false;
        _isLoading = false;
        notifyListeners();
      } else {
        await _fetchCurrentUser(firebaseUser.uid);
      }
    });
  }

  // ─── Theme ───
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String value = mode == ThemeMode.dark ? 'dark' : 'light';
      await prefs.setString('theme_mode', value);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  // ─── Fetch User from Firestore ───
  Future<void> _fetchCurrentUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _userService.getUserById(uid);

      if (user == null) {
        // Auth exists but no Firestore doc
        // Could be new Google user or orphaned state
        _currentUser = null;
        _needsOnboarding = true;
      } else if (!user.profileCompleted) {
        // User exists but hasn't completed onboarding
        _currentUser = user;
        _needsOnboarding = true;
      } else {
        _currentUser = user;
        _needsOnboarding = false;
        // Update last login timestamp
        _userService.updateLastLogin(uid);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Email + Password Sign In ───
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final authUser = await _authService.signInWithEmail(email, password);

      // Block access if email not verified
      if (authUser != null && !authUser.emailVerified) {
        // Don't sign them out — they need to verify
        throw Exception(
            'Please verify your email before signing in. Check your inbox.');
      }
      // Auth listener handles the rest
    } catch (e) {
      rethrow;
    }
  }

  // ─── Email + Password Sign Up ───
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      _isCreatingProfile = true;

      // 1. Create Auth User (sends verification email automatically)
      final authUser =
          await _authService.signUpWithEmail(email, password, name);
      if (authUser == null) throw Exception('Account creation failed');

      // 2. Create initial Firestore user doc (profileCompleted = false)
      final newUser = User(
        id: authUser.uid,
        name: name,
        email: email,
        isVerified: false,
        profileCompleted: false,
        reputationScore: 0,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _userService.createUser(newUser);

      _currentUser = newUser;
      _needsOnboarding = false; // They need to verify email first
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isCreatingProfile = false;
    }
  }

  // ─── Google Sign In ───
  Future<void> signInWithGoogle() async {
    try {
      _isCreatingProfile = true;

      final result = await _authService.signInWithGoogle();
      if (result.user == null) return; // Cancelled

      // Check if Firestore doc exists
      User? existingUser = await _userService.getUserById(result.user!.uid);

      if (existingUser != null) {
        // Existing user — go to home (or onboarding if incomplete)
        _currentUser = existingUser;
        _needsOnboarding = !existingUser.profileCompleted;
        _userService.updateLastLogin(result.user!.uid);
      } else {
        // New user — create doc and go to onboarding
        final newUser = User(
          id: result.user!.uid,
          name: result.user!.displayName ?? 'Student',
          email: result.user!.email ?? '',
          photoUrl: result.user!.photoURL,
          isVerified: true, // Google users are auto-verified
          profileCompleted: false, // Needs academic onboarding
          reputationScore: 0,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _userService.createUser(newUser);
        _currentUser = newUser;
        _needsOnboarding = true;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isCreatingProfile = false;
    }
  }

  // ─── Complete Academic Onboarding ───
  Future<void> completeOnboarding({
    required String campusId,
    required String branch,
    required int year,
    required int semester,
  }) async {
    if (_currentUser == null && _authService.currentUser != null) {
      // Edge case: user doc might not be loaded yet
      _currentUser =
          await _userService.getUserById(_authService.currentUser!.uid);
    }
    if (_currentUser == null) throw Exception('No user found');

    try {
      await _userService.completeOnboarding(
        userId: _currentUser!.id,
        campusId: campusId,
        branch: branch,
        year: year,
        semester: semester,
      );

      _currentUser = _currentUser!.copyWith(
        campusId: campusId,
        branch: branch,
        year: year,
        semester: semester,
        profileCompleted: true,
        academicUpdatedAt: DateTime.now(),
      );
      _needsOnboarding = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      rethrow;
    }
  }

  // ─── Sign Out ───
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _needsOnboarding = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // ─── Update User ───
  Future<void> updateUser(User user) async {
    _currentUser = user;
    await _userService.updateProfile(user);
    notifyListeners();
  }

  // ─── Reputation ───
  Future<void> updateReputationScore(int change) async {
    if (_currentUser == null) return;

    await _userService.updateReputationScore(_currentUser!.id, change);
    _currentUser = await _userService.getUserById(_currentUser!.id);
    notifyListeners();
  }

  // ─── Refresh ───
  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    _currentUser = await _userService.getUserById(_currentUser!.id);
    notifyListeners();
  }

  // ─── Email Management ───
  Future<void> changeEmail(String newEmail, String? password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.reauthenticate(password: password);
      await _authService.updateEmail(newEmail);
      await _userService.updateEmailInFirestore(_currentUser!.id, newEmail);
      await refreshUser();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Password Management ───
  Future<void> changePassword(
      String? currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.reauthenticate(password: currentPassword);
      await _authService.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Delete Account ───
  Future<void> deleteAccount(String? password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.reauthenticate(password: password);

      final uid = _currentUser!.id;
      await _userService.deleteUserDocument(uid);
      await _authService.deleteAccount();

      _currentUser = null;
      _needsOnboarding = false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Privacy Settings ───
  Future<void> updatePrivacySettings(Map<String, bool> settings) async {
    if (_currentUser == null) return;
    try {
      final updatedUser = _currentUser!.copyWith(privacySettings: settings);
      _currentUser = updatedUser;
      notifyListeners();
      await _userService.updatePrivacySettings(updatedUser.id, settings);
    } catch (e) {
      await refreshUser();
      rethrow;
    }
  }

  // ─── Notification Settings ───
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    if (_currentUser == null) return;
    try {
      final updatedUser =
          _currentUser!.copyWith(notificationSettings: settings);
      _currentUser = updatedUser;
      notifyListeners();
      await _userService.updateNotificationSettings(updatedUser.id, settings);
    } catch (e) {
      await refreshUser();
      rethrow;
    }
  }

  // ─── Email Verification ───
  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> reloadAuthUser() async {
    await _authService.reloadUser();
    final authUser = _authService.currentUser;

    if (authUser != null && authUser.emailVerified) {
      if (_currentUser != null && !_currentUser!.isVerified) {
        final updatedUser = _currentUser!.copyWith(isVerified: true);
        _currentUser = updatedUser;
        await _userService.updateProfile(updatedUser);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
