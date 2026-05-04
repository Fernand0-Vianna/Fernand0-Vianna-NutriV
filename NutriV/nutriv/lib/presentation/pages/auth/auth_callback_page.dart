import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/di/injection.dart';
import '../../../data/datasources/auth_service.dart';
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
      await Future.delayed(const Duration(milliseconds: 500));

      // Verifica se há sessão ativa após redirect do OAuth
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;

      debugPrint('🔄 AuthCallback: Session = ${session != null}');
      debugPrint('🔄 AuthCallback: User = ${user?.email}');

      if (session != null && user != null) {
        // Usuário autenticado com sucesso
        final authService = getIt<AuthService>();
        final appUser = authService.getCurrentUser();

        if (appUser != null && mounted) {
          debugPrint('✅ AuthCallback: Usuário autenticado - ${appUser.email}');
          context.read<UserBloc>().add(SaveUser(appUser));
          context.go('/');
          return;
        }
      }

      // Se não há sessão, tenta recuperar do localStorage (fallback)
      debugPrint('⚠️ AuthCallback: Sem sessão, tentando recuperar...');
      await Supabase.instance.client.auth.refreshSession();

      final refreshedSession = Supabase.instance.client.auth.currentSession;
      if (refreshedSession != null && mounted) {
        final authService = getIt<AuthService>();
        final appUser = authService.getCurrentUser();
        if (appUser != null) {
          context.read<UserBloc>().add(SaveUser(appUser));
          context.go('/');
          return;
        }
      }

      // Se não há sessão, volta para login
      debugPrint('❌ AuthCallback: Falha na autenticação');
      if (mounted) {
        context.go('/login');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro no callback de auth: $e');
      debugPrint('❌ Stack trace: $stackTrace');
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
