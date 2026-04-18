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
      // Verifica se há sessão ativa após redirect do OAuth
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        // Usuário autenticado com sucesso
        final authService = getIt<AuthService>();
        final user = authService.getCurrentUser();
        
        if (user != null && mounted) {
          context.read<UserBloc>().add(SaveUser(user));
          context.go('/');
          return;
        }
      }
      
      // Se não há sessão, volta para onboarding
      if (mounted) {
        context.go('/onboarding');
      }
    } catch (e) {
      debugPrint('Erro no callback de auth: $e');
      if (mounted) {
        context.go('/onboarding');
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
