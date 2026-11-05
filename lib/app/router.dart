import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/welcome/presentation/welcome_screen.dart';
import '../features/discovery/presentation/discovery_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../shared/widgets/main_navigation_shell.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/register_screen.dart';
import '../features/discovery/presentation/cultural_detail_screen.dart';
import '../features/welcome/presentation/wonderous_intro_screen.dart';
import '../features/discovery/presentation/destination_detail_screen.dart';
import '../features/discovery/presentation/interactive_map_screen.dart';
import '../features/discovery/presentation/ai_assistant_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => WonderousIntroScreen(
        onExplore: () {
          context.go('/welcome');
        },
      ),
    ),

    GoRoute(
      path: '/welcome',
      builder: (context, state) => WelcomeScreen(
        onStartExploring: () => context.go('/home'),
        onSignIn: () => context.push('/login'),
      ),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/discover',
              builder: (context, state) => const DiscoveryScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/cultural/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return CulturalDetailScreen(culturalId: id);
      },
    ),

    GoRoute(
      path: '/destination/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DestinationDetailScreen(destinationId: id);
      },
    ),

    GoRoute(
      path: '/map',
      builder: (context, state) => const InteractiveMapScreen(),
    ),

    GoRoute(
      path: '/ai-assistant',
      builder: (context, state) => const AiAssistantScreen(),
    ),
  ],
);
