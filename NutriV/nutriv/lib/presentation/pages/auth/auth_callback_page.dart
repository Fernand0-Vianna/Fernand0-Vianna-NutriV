import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../../core/di/injection.dart';
import '../../../data/datasources/auth_service.dart';
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
      debugPrint('🔄 AuthCallback: Iniciando processamento...');

      // Aguarda um momento para o Supabase processar o callback
      await Future.delayed(const Duration(milliseconds: 800));

      // Verifica se há sessão ativa após redirect do OAuth
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      debugPrint('🔄 AuthCallback: Session = ${session != null}');
      debugPrint('🔄 AuthCallback: User = ${user?.email}');

      if (session != null && user != null) {
        // Usuário autenticado com sucesso
        final authService = getIt<AuthService>();

        debugPrint('🔄 AuthCallback: Buscando perfil completo...');

        // Tenta buscar perfil completo do Supabase
        User? profile;
        try {
          profile = await authService.fetchUserProfileFromSupabase();
        } catch (e) {
          debugPrint('⚠️ AuthCallback: Erro ao buscar perfil do Supabase: $e');
        }

        if (profile != null) {
          debugPrint('✅ AuthCallback: Perfil encontrado - ${profile.email}');
          if (mounted) {
            context.read<UserBloc>().add(SaveUser(profile));
            context.go('/');
            return;
          }
        }

        debugPrint(
            '⚠️ AuthCallback: Perfil não encontrado, usando getCurrentUser como fallback...');

        // Fallback: tenta obter do getCurrentUser
        final appUser = authService.getCurrentUser();
        if (appUser != null && mounted) {
          debugPrint(
              '✅ AuthCallback: Usuário via getCurrentUser - ${appUser.email}');
          context.read<UserBloc>().add(SaveUser(appUser));
          context.go('/');
          return;
        }

        // Último fallback: cria usuário padrão temporário para não ficar em loop
        debugPrint(
            '⚠️ AuthCallback: Criando usuário default como último fallback...');
        final defaultUser = User(
          id: user.id,
          name: user.userMetadata?['name'] ??
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'Usuário',
          email: user.email,
          photoUrl:
              user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
          weight: 70,
          height: 170,
          age: 30,
          isMale: true,
          activityLevel: 1,
          goal: 'maintain',
          calorieGoal: 2000,
          proteinGoal: 150,
          carbsGoal: 250,
          fatGoal: 65,
          waterGoal: 2000,
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
      debugPrint('⚠️ AuthCallback: Sem sessão, tentando refresh...');
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
      debugPrint('❌ AuthCallback: Falha total, indo para login');
      if (mounted) {
        context.go('/login');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro no callback: $e');
      debugPrint('❌ Stack: $stackTrace');
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
