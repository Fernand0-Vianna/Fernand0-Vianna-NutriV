import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/daily_log/presentation/providers/daily_log_provider.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'routes/app_router.dart';

class NutriVisionApp extends StatelessWidget {
  const NutriVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DailyLogProvider()),
        // Adicionar outros providers aqui
      ],
      child: MaterialApp.router(
        title: 'NutriVision',
        theme: AppTheme.lightTheme, // Definir tema claro
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router, // Configurar GoRouter
      ),
    );
  }
}