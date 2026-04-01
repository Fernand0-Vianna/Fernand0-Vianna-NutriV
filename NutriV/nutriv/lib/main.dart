import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'presentation/bloc/user/user_bloc.dart';
import 'presentation/bloc/user/user_event.dart';
import 'presentation/bloc/meal/meal_bloc.dart';
import 'presentation/bloc/meal/meal_event.dart';
import 'presentation/bloc/food_scanner/food_scanner_bloc.dart';
import 'presentation/bloc/water/water_bloc.dart';
import 'presentation/bloc/water/water_event.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/pages/diary/diary_page.dart';
import 'presentation/pages/scanner/scanner_page.dart';
import 'presentation/pages/profile/profile_page.dart';
import 'presentation/pages/profile/progress_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/main/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const NutriVApp());
}

class NutriVApp extends StatelessWidget {
  const NutriVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (_) => getIt<UserBloc>()..add(LoadUser()),
        ),
        BlocProvider<MealBloc>(
          create: (_) => getIt<MealBloc>()..add(LoadMeals(DateTime.now())),
        ),
        BlocProvider<FoodScannerBloc>(create: (_) => getIt<FoodScannerBloc>()),
        BlocProvider<WaterBloc>(
          create: (_) =>
              getIt<WaterBloc>()..add(LoadWaterIntake(DateTime.now())),
        ),
      ],
      child: MaterialApp.router(
        title: 'NutriV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(path: '/diary', builder: (context, state) => const DiaryPage()),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/progress',
          builder: (context, state) => const ProgressPage(),
        ),
      ],
    ),
  ],
);
