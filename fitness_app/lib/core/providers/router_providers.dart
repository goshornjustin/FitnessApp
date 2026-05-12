/// App router configuration using GoRouter.
///
/// [routerProvider] builds a `GoRouter` that watches [authStateProvider] and
/// applies redirect logic on every navigation event:
///
/// - `/splash` — shown while auth state is loading; redirects to `/` or
///   `/auth` once resolved.
/// - Unauthenticated users are always redirected to `/auth`.
/// - Authenticated users whose profile is incomplete (`age == 0` or empty
///   name) are redirected to `/profile/setup` before reaching any other route.
/// - Authenticated users with a complete profile on `/auth` are bounced to `/`.
library;

import 'package:fitness_app/features/authentication/presentation/pages/auth_page.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/home/presentation/pages/home_page.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_page.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_setup_page.dart';
import 'package:fitness_app/shared/widgets/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (_, __) => const ProfilePage(),
      ),
      GoRoute(
        path: '/profile/setup',
        builder: (_, __) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      return authState.when(
        data: (user) {
          final isAuth = user != null;
          if (loc == '/splash') {
            return isAuth ? '/' : '/auth';
          }

          if (!isAuth) {
            return loc == '/auth' ? null : '/auth';
          }

          // Authenticated — check if profile is complete
          final profileIncomplete = user.age == 0 || user.name.isEmpty;
          if (profileIncomplete && loc != '/profile/setup') {
            return '/profile/setup';
          }

          if (loc == '/auth') return '/';

          return null;
        },
        loading: () => loc == '/splash' ? null : '/splash',
        error: (_, __) => '/auth',
      );
    },
  );
});
