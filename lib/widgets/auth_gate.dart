import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/screens/auth_screen.dart';
import 'package:studentrank/screens/splash_screen.dart';
import 'package:studentrank/screens/verify_email_screen.dart';
import 'package:studentrank/screens/main_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplashEvent = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Enforce minimum splash time for branding/animation
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplashEvent = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // 1. Show Splash if enforcing min duration OR app is loading auth state
        if (_showSplashEvent || provider.isLoading) {
          return const SplashScreen();
        }

        // 2. If not authenticated -> AuthScreen / Welcome
        if (!provider.isAuthenticated) {
          return const AuthScreen();
        }

        // 3. Authenticated but no user doc (Zombie/Recovery)
        // Provider handles recovery, so if _currentUser is null here implies failure or strict loading
        if (provider.currentUser == null) {
          // Keep showing splash or a specific loading/error screen
          return const SplashScreen();
        }

        // 4. Verification Check
        // If not guest and not verified, show verification screen
        if (!provider.currentUser!.isGuest &&
            !provider.currentUser!.isVerified) {
          return const VerifyEmailScreen();
        }

        // 5. Authenticated & Verified -> Main App
        // Navigate to the main functionality
        // We return the Nav/Main screen directly here.
        // If we want to change URL, we would do it in initState or listener,
        // but for AuthGate as the root widget, returning the widget is clean.
        return const MainScreen();
      },
    );
  }
}
