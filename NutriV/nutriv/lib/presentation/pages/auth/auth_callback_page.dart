import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../core/di/injection.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/auth_service.dart';
import '../../../core/services/logging_service.dart';
import '../../../domain/entities/user.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';

/// Página para processar callback de autenticação OAuth (Google)
class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      LoggingService.auth('AuthCallback: Iniciando processamento...');

      // Aguarda um momento para o Supabase processar o callback
      await Future.delayed(const Duration(milliseconds: 800));

      // Verifica se há sessão ativa após redirect do OAuth
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      LoggingService.auth('AuthCallback: Session = ${session != null}');
      LoggingService.auth('AuthCallback: User = ${user?.email}');

      if (session != null && user != null) {
        // Usuário autenticado com sucesso
        final authService = getIt<AuthService>();

        LoggingService.auth('AuthCallback: Buscando perfil completo...');

        // Tenta buscar perfil completo do Supabase
        User? profile;
        try {
          profile = await authService.fetchUserProfileFromSupabase();
        } catch (e) {
          LoggingService.error('AuthCallback', 'fetchUserProfileFromSupabase', e);
        }

        if (profile != null) {
          LoggingService.auth('AuthCallback: Perfil encontrado - ${profile.email}');
          if (mounted) {
            context.read<UserBloc>().add(SaveUser(profile));
            // Verificar se é usuário novo (sem dados configurados = peso 0)
            if (profile.weight == 0 || profile.weight == 70) {
              // Usuário novo - redireciona para home
              LoggingService.auth('AuthCallback: Novo usuário, redirecionando para home...');
              context.go('/');
            } else {
              context.go('/');
            }
            return;
          }
        }

        LoggingService.auth(
            'AuthCallback: Perfil não encontrado, usando getCurrentUser como fallback...');

        // Fallback: tenta obter do getCurrentUser
        final appUser = authService.getCurrentUser();
        if (appUser != null && mounted) {
          LoggingService.auth(
              'AuthCallback: Usuário via getCurrentUser - ${appUser.email}');
          context.read<UserBloc>().add(SaveUser(appUser));
          // Verificar se é usuário novo
          if (appUser.weight == 0) {
            LoggingService.auth('AuthCallback: Novo usuário via fallback, redirecionando para home...');
            context.go('/');
          } else {
            context.go('/');
          }
          return;
        }

        // Último fallback: cria usuário padrão com metas calculadas automaticamente
        LoggingService.auth(
            'AuthCallback: Criando usuário com metas calculadas automaticamente...');

        // Valores padrão razoáveis para novos usuários
        const defaultWeight = 70.0;
        const defaultHeight = 170.0;
        const defaultAge = 30;
        const defaultIsMale = true;
        const defaultActivityLevel = 1;
        const defaultGoal = 'maintain';

        // Calcular metas automaticamente usando TMB/TDEE
        final bmr = NutritionUtils.calculateBMR(
          weight: defaultWeight,
          height: defaultHeight,
          age: defaultAge,
          isMale: defaultIsMale,
        );
        final tdee = NutritionUtils.calculateTDEE(bmr, defaultActivityLevel);
        final calorieGoal = NutritionUtils.calculateGoalCalories(tdee, defaultGoal);
        final proteinGoal = defaultWeight * 1.6;
        final carbsGoal = calorieGoal * 0.4 / 4;
        final fatGoal = calorieGoal * 0.3 / 9;
        final waterGoal = WaterUtils.calculateWaterGoal(
          weightKg: defaultWeight,
          activityLevel: defaultActivityLevel,
        );

        final defaultUser = User(
          id: user.id,
          name: user.userMetadata?['name'] ??
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'Usuário',
          email: user.email,
          photoUrl:
              user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
          weight: defaultWeight,
          height: defaultHeight,
          age: defaultAge,
          isMale: defaultIsMale,
          activityLevel: defaultActivityLevel,
          goal: defaultGoal,
          calorieGoal: calorieGoal,
          proteinGoal: proteinGoal,
          carbsGoal: carbsGoal,
          fatGoal: fatGoal,
          waterGoal: waterGoal,
          createdAt: DateTime.now(),
        );

        // Salva no UserBloc para persistência local
        if (mounted) {
          context.read<UserBloc>().add(SaveUser(defaultUser));
          context.go('/');
          return;
        }
      }

      // Se não há sessão, tenta refresh
      LoggingService.auth('AuthCallback: Sem sessão, tentando refresh...');
      await Supabase.instance.client.auth.refreshSession();

      final refreshedSession = Supabase.instance.client.auth.currentSession;
      final refreshedUser = Supabase.instance.client.auth.currentUser;

      if (refreshedSession != null && refreshedUser != null && mounted) {
        final authService = getIt<AuthService>();
        final appUser = authService.getCurrentUser();
        if (appUser != null) {
          context.read<UserBloc>().add(SaveUser(appUser));
          context.go('/');
          return;
        }
      }

      // Se não há sessão mesmo após refresh, volta para login
      LoggingService.error('AuthCallback', 'auth_callback', 'Falha total, indo para login');
      if (mounted) {
        context.go('/login');
      }
    } catch (e, stackTrace) {
      LoggingService.error('AuthCallback', 'callback error', e);
      LoggingService.error('AuthCallback', 'callback stack', stackTrace);
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processando login...'),
          ],
        ),
      ),
    );
  }
}
