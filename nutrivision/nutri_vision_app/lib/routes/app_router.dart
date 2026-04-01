import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/archives/presentation/screens/archives_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/capture/presentation/screens/capture_screen.dart';
import '../features/daily_log/presentation/screens/daily_log_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/training/presentation/screens/training_screen.dart';
import '../shared/widgets/custom_bottom_nav_bar.dart'; // Nosso shell principal
import 'app_routes.dart';

// O GoRouter precisa de um Root Navigator para o BottomNavBar funcionar corretamente.
// Usamos um StatefulShellRoute para o bottom navigation.
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Retornamos nosso CustomBottomNavBar, passando o navigationShell
          return CustomBottomNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Home Branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shellHome'),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          // Daily Log Branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shellDailyLog'),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.dailyLog,
                builder: (BuildContext context, GoRouterState state) =>
                    const DailyLogScreen(),
              ),
            ],
          ),
          // Capture Branch (special case, could navigate to a full screen modal or new route)
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shellCapture'),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.capture,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: const CaptureScreen(),
                ),
                // builder: (BuildContext context, GoRouterState state) =>
                //     const CaptureScreen(),
              ),
            ],
          ),
          // Archives Branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shellArchives'),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.archives,
                builder: (BuildContext context, GoRouterState state) =>
                    const ArchivesScreen(),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shellProfile'),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
          // Training Branch (From Home Screen)
          StatefulShellBranch(
            navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shellTraining'),
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.training,
                builder: (BuildContext context, GoRouterState state) =>
                    const TrainingScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    // Redirecionamento (ex: se não estiver logado, ir para login)
    redirect: (context, state) {
      // Exemplo simples, o AuthProvider deve gerenciar isso
      final bool loggedIn =
          Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
      final bool goingToLogin = state.matchedLocation == AppRoutes.login;
      final bool goingToSplash = state.matchedLocation == AppRoutes.splash;

      if (!loggedIn && !goingToLogin && !goingToSplash) {
        return AppRoutes.login;
      }
      if (loggedIn && goingToLogin) {
        return AppRoutes.home;
      }
      return null; // Nenhuma redireção necessária
    },
  );
}