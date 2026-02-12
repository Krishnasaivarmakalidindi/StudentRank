import 'dart:async';
import 'package:flutter/material.dart' hide Badge;
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
  bool _isCreatingProfile =
      false; // Guard against race conditions during sign-up/recovery
  StreamSubscription<auth.User?>? _authSubscription;
  ThemeMode _themeMode = ThemeMode.system;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  // We check firebase auth state via authService (or local cache)
  // But cleaner to rely on _currentUser being populated for "Full Auth"
  // However, for AuthGate, we need to distinguish "Not Logged In" vs "Logged In but loading profile"
  bool get isAuthenticated => _authService.currentUser != null;
  ThemeMode get themeMode => _themeMode;

  bool get isPasswordAuth {
    final user = _authService.currentUser;
    return user?.providerData.any((p) => p.providerId == 'password') ?? false;
  }

  AppProvider() {
    _init();
  }

  void _init() async {
    // Load theme
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme_mode');
      if (themeString != null) {
        if (themeString == 'light') {
          _themeMode = ThemeMode.light;
        } else if (themeString == 'dark')
          _themeMode = ThemeMode.dark;
        else
          _themeMode = ThemeMode.system;
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }

    _authSubscription =
        _authService.authStateChanges.listen((auth.User? firebaseUser) async {
      if (_isCreatingProfile) {
        // Skip automatic fetching if we are in the middle of manually creating a profile
        // The manual process will handle fetching/setting the user and notifying listeners.
        return;
      }
      if (firebaseUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        await _fetchCurrentUser(firebaseUser.uid);
      }
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      String value = 'system';
      if (mode == ThemeMode.light) value = 'light';
      if (mode == ThemeMode.dark) value = 'dark';
      await prefs.setString('theme_mode', value);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  Future<void> _fetchCurrentUser(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _userService.getUserById(uid);

      if (user == null) {
        // Data Recovery / Zombie State
        // Logic: If we are here, Firebase Auth says we are logged in.
        // But Firestore has no doc. This happens if creation failed or doc was deleted.
        // We should attempt to create a basic doc to "recover".
        debugPrint(
            "⚠️ Zombie State Detected: Auth exists but no Firestore doc. Attempting recovery.");

        // Try to reconstruct basic info from Auth
        final authUser = _authService.currentUser;
        if (authUser != null) {
          final recoveredUser = User(
            id: authUser.uid,
            name: authUser.displayName ?? "Recovered User",
            email: authUser.email ?? "",
            joinedDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isVerified: authUser.emailVerified,
            profileCompleted: false,
            reputationScore: 0,
            level: 1,
            collegeRank: 0,
            subjects: [],
            badges: [],
          );
          await _userService.createUser(recoveredUser);
          user = recoveredUser;
        }
      }

      _currentUser = user;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Auth Methods
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      // _isLoading = true; // interactively handled by UI
      // notifyListeners();

      // 1. Auth Service
      await _authService.signInWithEmail(email, password);
      // 2. Auth State listener will handle fetching user
      // We don't wait for listener here, but listener will eventually update currentUser
      // But we might want to wait for listener to complete?
      // Actually, standard pattern is fire and forget or await result.
      // Since _authService.signIn returns, the AuthState stream fires.
      // fetchCurrentUser sets _isLoading.
      // So checking _fetchCurrentUser logic:
      // _authSubscription calls _fetchCurrentUser which sets _isLoading = true!
    } catch (e) {
      rethrow;
    } finally {
      // _isLoading = false;
      // notifyListeners();
    }
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      _isCreatingProfile = true;

      // 1. Create Auth User
      final authUser = await _authService.signUpWithEmail(email, password);
      if (authUser == null) throw Exception("Auth creation failed");

      // 2. Create Firestore User
      final newUser = User(
        id: authUser.uid,
        name: name,
        email: email,
        joinedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: false,
        profileCompleted: true,
        reputationScore: 0,
        collegeRank: 0,
        level: 1,
        subjects: [],
        badges: [],
      );

      await _userService.createUser(newUser);

      // 3. Set local state (Optional, as listener will eventually catch up, but this is faster)
      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isCreatingProfile = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isCreatingProfile = true;

      // 1. SignIn Google
      final authUser = await _authService.signInWithGoogle();
      if (authUser == null) {
        return; // Cancelled
      }

      // 2. Check/Create Firestore
      User? user = await _userService.getUserById(authUser.uid);
      if (user == null) {
        final newUser = User(
          id: authUser.uid,
          name: authUser.displayName ?? "Student",
          email: authUser.email ?? "",
          joinedDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: authUser.emailVerified,
          profileCompleted: true,
          reputationScore: 0,
          collegeRank: 0,
          level: 1,
          subjects: [],
          badges: [],
          profileImageUrl: authUser.photoURL,
        );
        await _userService.createUser(newUser);
        _currentUser = newUser;
      } else {
        _currentUser = user;
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isCreatingProfile = false;
    }
  }

  Future<void> signInAnonymously(String name, String educationLevel) async {
    try {
      _isCreatingProfile = true;

      // 1. Auth Guest
      final authUser = await _authService.signInAnonymously();
      if (authUser == null) throw Exception("Guest auth failed");

      // 2. Firestore Guest
      final newUser = User(
        id: authUser.uid,
        name: name,
        educationLevel: educationLevel,
        isGuest: true,
        joinedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        profileCompleted: true,
        reputationScore: 0,
        collegeRank: 0,
        level: 1,
        subjects: [],
        badges: [],
      );

      await _userService.createUser(newUser);
      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isCreatingProfile = false;
    }
  }

  Future<void> createDemoUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final authUser = await _authService.signInAnonymously();
      if (authUser == null) throw Exception("Demo auth failed");

      final demoUser = User(
        id: authUser.uid,
        name: "Demo User",
        isDemo: true, // Specific flag for demo
        profileCompleted: true,
        joinedDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        reputationScore: 1250,
        level: 3,
        collegeRank: 42,
        collegeName: "Demo University",
        educationLevel: "Undergraduate",
        bio: "Exploring StudentRank capabilities.",
        subjects: ["Computer Science", "Mathematics"],
        badges: [
          Badge(
            id: "demo_badge_1",
            name: "Early Adopter",
            description: "Joined during beta",
            iconName: "star",
            earnedDate: DateTime.now(),
          ),
          Badge(
            id: "demo_badge_2",
            name: "First Quiz",
            description: "Completed first quiz",
            iconName: "quiz",
            earnedDate: DateTime.now(),
          )
        ],
      );

      await _userService.createUser(demoUser);
      _currentUser = demoUser;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<void> updateUser(User user) async {
    _currentUser = user;
    await _userService.updateProfile(user);
    notifyListeners();
  }

  Future<void> updateReputationScore(int change) async {
    if (_currentUser == null) return;

    await _userService.updateReputationScore(_currentUser!.id, change);
    // Refresh to get new level/score
    _currentUser = await _userService.getUserById(_currentUser!.id);
    notifyListeners();
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    _currentUser = await _userService.getUserById(_currentUser!.id);
    notifyListeners();
  }

  Future<void> changeEmail(String newEmail, String? password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Auth update
      await _authService.reauthenticate(password: password);
      await _authService.updateEmail(newEmail);

      // 2. Firestore update
      await _userService.updateEmailInFirestore(_currentUser!.id, newEmail);

      // Refresh user to get new email
      await refreshUser();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> deleteAccount(String? password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Auth Recheck
      await _authService.reauthenticate(password: password);

      final uid = _currentUser!.id;

      // 2. Delete Firestore
      await _userService.deleteUserDocument(uid);

      // 3. Delete Auth
      await _authService.deleteAccount();

      _currentUser = null;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePrivacySettings(Map<String, bool> settings) async {
    if (_currentUser == null) return;
    try {
      final updatedUser = _currentUser!.copyWith(privacySettings: settings);
      _currentUser = updatedUser;
      notifyListeners(); // Optimistic update

      await _userService.updatePrivacySettings(updatedUser.id, settings);
    } catch (e) {
      // Revert on failure
      await refreshUser();
      rethrow;
    }
  }

  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    if (_currentUser == null) return;
    try {
      final updatedUser =
          _currentUser!.copyWith(notificationSettings: settings);
      _currentUser = updatedUser;
      notifyListeners(); // Optimistic update

      await _userService.updateNotificationSettings(updatedUser.id, settings);
    } catch (e) {
      // Revert on failure
      await refreshUser();
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<void> reloadAuthUser() async {
    await _authService.reloadUser();
    final authUser = _authService.currentUser;

    // Sync verification status if changed
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
