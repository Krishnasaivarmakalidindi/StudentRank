import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studentrank/models/user.dart';
import 'package:studentrank/services/user_service.dart';

class AppProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoading = true;
  StreamSubscription? _authSubscription;
  ThemeMode _themeMode = ThemeMode.system;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  ThemeMode get themeMode => _themeMode;

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
        _userService.authStateChanges.listen((auth.User? firebaseUser) async {
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

      // If user doc doesn't exist but we are auth'd, it might be a race condition
      // or initial creation lag. But generally we expect the doc to exist if
      // we are in a steady state. If it's a new signup, the signUp method
      // returns the user object directly, so we might not need to fetch immediately
      // there, but this listener catches app restarts.

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
      _isLoading = true;
      notifyListeners();
      _currentUser =
          await _userService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser =
          await _userService.signUpWithEmailAndPassword(email, password, name);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _userService.signInWithGoogle();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInAnonymously(String name, String educationLevel) async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _userService.signInAnonymously(name, educationLevel);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDemoUser() async {
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await _userService.createDemoUser();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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

  Future<void> changeEmail(String newEmail, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.changeEmail(newEmail, password);
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
      String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _userService.deleteAccount(password);
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
