import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/onboarding_screen_enhanced.dart';
import '../screens/scout/scout_screen.dart';
import '../screens/audit/business_detail_screen.dart';
import '../screens/pipeline/pipeline_screen_enhanced.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/build/build_demo_screen.dart';
import '../screens/outreach/outreach_screen.dart';
import '../widgets/app_bottom_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // Not logged in -> go to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Logged in but on login screen -> go to dashboard
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }

      // Check if user needs onboarding
      if (isLoggedIn && authState.needsOnboarding && !isOnboarding) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreenEnhanced(),
      ),

      // Main Shell with Bottom Nav (5 branches)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppBottomNav(navigationShell: navigationShell),
        branches: [
          // 0 - Home / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // 1 - Pipeline
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pipeline',
                builder: (context, state) => const PipelineScreenEnhanced(),
              ),
            ],
          ),
          // 2 - Scout (center FAB)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/scout',
                builder: (context, state) => const ScoutScreen(),
              ),
            ],
          ),
          // 3 - Messages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) => const MessagesScreen(),
              ),
            ],
          ),
          // 4 - Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Business Detail (full screen, no bottom nav)
      GoRoute(
        path: '/business/:id',
        builder: (context, state) {
          final businessId = state.pathParameters['id']!;
          return BusinessDetailScreen(businessId: businessId);
        },
      ),

      // Build Demo (full screen, no bottom nav)
      GoRoute(
        path: '/business/:id/build-demo',
        builder: (context, state) {
          final businessId = state.pathParameters['id']!;
          return BuildDemoScreen(businessId: businessId);
        },
      ),

      // Outreach (full screen, no bottom nav)
      GoRoute(
        path: '/business/:id/outreach',
        builder: (context, state) {
          final businessId = state.pathParameters['id']!;
          return OutreachScreen(businessId: businessId);
        },
      ),
    ],
  );
});
