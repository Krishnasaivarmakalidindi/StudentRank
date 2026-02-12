import 'package:go_router/go_router.dart';
import 'package:studentrank/providers/app_provider.dart';
import 'package:studentrank/screens/auth_screen.dart';
// SplashScreen import removed as it's not used directly anymore (used in AuthGate)
import 'package:studentrank/screens/welcome_screen.dart';
import 'package:studentrank/screens/main_screen.dart';
import 'package:studentrank/screens/contribute_screen.dart';
import 'package:studentrank/screens/resource_detail_screen.dart';
import 'package:studentrank/screens/group_detail_screen.dart';
import 'package:studentrank/screens/settings_screen.dart';
import 'package:studentrank/screens/settings/edit_profile_screen.dart';
import 'package:studentrank/screens/settings/verification_screen.dart';
import 'package:studentrank/screens/settings/change_email_screen.dart';
import 'package:studentrank/screens/settings/security_screen.dart';
import 'package:studentrank/screens/settings/privacy_screen.dart';
import 'package:studentrank/screens/settings/notifications_screen.dart';
import 'package:studentrank/screens/settings/about_screen.dart';
import 'package:studentrank/screens/settings/help_screen.dart';
import 'package:studentrank/screens/settings/language_screen.dart';

import 'package:studentrank/widgets/auth_gate.dart';

class AppRouter {
  static GoRouter createRouter(AppProvider appProvider) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: appProvider,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: AppRoutes.splash, // The root '/' path
          name: 'splash',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AuthGate()),
        ),
        // Auth route can still exist for explicit navigation, but AuthGate handles initial logic
        GoRoute(
          path: AppRoutes.auth,
          name: 'auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          name: 'welcome',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WelcomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.main,
          name: 'main',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MainScreen()),
        ),
        GoRoute(
          path: AppRoutes.contribute,
          name: 'contribute',
          builder: (context, state) => const ContributeScreen(),
        ),
        GoRoute(
          path: '/resource/:id',
          name: 'resource',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ResourceDetailScreen(resourceId: id);
          },
        ),
        GoRoute(
          path: '/group/:id',
          name: 'group',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return GroupDetailScreen(groupId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'edit-profile',
              name: 'edit-profile',
              builder: (context, state) => const EditProfileScreen(),
            ),
            GoRoute(
              path: 'verification',
              name: 'verification',
              builder: (context, state) => const VerificationStatusScreen(),
            ),
            GoRoute(
              path: 'change-email',
              name: 'change-email',
              builder: (context, state) => const ChangeEmailScreen(),
            ),
            GoRoute(
              path: 'security',
              name: 'security',
              builder: (context, state) => const SecurityScreen(),
            ),
            GoRoute(
              path: 'privacy',
              name: 'privacy',
              builder: (context, state) => const PrivacySettingsScreen(),
            ),
            GoRoute(
              path: 'notifications',
              name: 'notifications',
              builder: (context, state) => const NotificationsSettingsScreen(),
            ),
            GoRoute(
              path: 'about',
              name: 'about',
              builder: (context, state) => const AboutScreen(),
            ),
            GoRoute(
              path: 'help',
              name: 'help',
              builder: (context, state) => const HelpCenterScreen(),
            ),
            GoRoute(
              path: 'language',
              name: 'language',
              builder: (context, state) => const LanguageScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        // Redirection logic simplified: AuthGate handles the root splash/auth/home decision
        // We only need to protect other routes if somehow accessed directly

        final isLoggedIn = appProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == AppRoutes.auth ||
            state.matchedLocation == AppRoutes.welcome ||
            state.matchedLocation == AppRoutes.splash;

        // If trying to access protected route (anything not in isAuthRoute)
        // and not logged in, redirect to auth/welcome
        if (!isLoggedIn && !isAuthRoute) {
          return AppRoutes.auth;
        }

        // We do NOT redirect FROM splash/auth TO main here, because AuthGate does that.
        // If we did, it might fight with AuthGate or cause loops.

        return null;
      },
    );
  }
}

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String auth = '/auth';
  static const String main = '/main';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String contribute = '/contribute';
  static const String groups = '/groups';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
