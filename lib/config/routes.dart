import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/scout/scout_screen.dart';
import '../screens/audit/business_detail_screen.dart';
import '../screens/pipeline/pipeline_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/app_bottom_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/scout',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.location == '/login';
      final isOnboarding = state.location == '/onboarding';
      
      // Not logged in → go to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // Logged in but on login screen → go to scout
      if (isLoggedIn && isLoggingIn) {
        return '/scout';
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
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main Shell with Bottom Nav
      ShellRoute(
        builder: (context, state, child) => AppBottomNav(child: child),
        routes: [
          // Scout
          GoRoute(
            path: '/scout',
            builder: (context, state) => const ScoutScreen(),
          ),
          
          // Pipeline
          GoRoute(
            path: '/pipeline',
            builder: (context, state) => const PipelineScreen(),
          ),
          
          // Dashboard
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Settings
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
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
    ],
  );
});
