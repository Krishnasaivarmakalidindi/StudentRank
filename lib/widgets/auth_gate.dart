import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/screens/auth/academic_onboarding_screen.dart';
import 'package:studentrank/screens/auth/auth_screen.dart';
import 'package:studentrank/screens/splash_screen.dart';

import 'package:studentrank/screens/main_screen.dart';

/// AuthGate — Central navigation controller for authentication flow.
///
/// Flow:
/// 1. Splash (loading / branding)
/// 2. Not authenticated → AuthScreen
/// 3. Authenticated but email not verified → VerifyEmailScreen
/// 4. Authenticated + verified but no profile/onboarding → AcademicOnboardingScreen
/// 5. Fully set up → MainScreen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Minimum splash duration for branding
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSplash = false);
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
        // 1. Splash — loading or enforcing min duration
        if (_showSplash || provider.isLoading) {
          return const SplashScreen();
        }

        // 2. Not authenticated → Auth Screen
        if (!provider.isAuthenticated) {
          return const AuthScreen();
        }

        // 3. Authenticated but user doc loading or recovery
        if (provider.currentUser == null && !provider.needsOnboarding) {
          return const SplashScreen();
        }



        // 5. Needs academic onboarding (first-time users)
        if (provider.needsOnboarding) {
          return const AcademicOnboardingScreen();
        }

        // Also check profileCompleted on the user object
        if (provider.currentUser != null &&
            !provider.currentUser!.profileCompleted) {
          return const AcademicOnboardingScreen();
        }

        // 6. Fully authenticated and onboarded → Main App
        return const MainScreen();
      },
    );
  }
}
