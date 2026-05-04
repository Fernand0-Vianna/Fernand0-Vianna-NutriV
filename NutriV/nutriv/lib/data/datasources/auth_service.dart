import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/user.dart' as app;
import '../repositories/user_repository.dart';

class AuthService {
  final SupabaseClient _supabase;
  final UserRepository _userRepository;

  AuthService(this._supabase, this._userRepository);

  Future<app.User?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = _createUserFromSupabase(response.user!);
        await _userRepository.saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing in with email: $e');
      }
      rethrow;
    }
  }

  Future<app.User?> signUpWithEmail(String email, String password) async {
    try {
      if (kDebugMode) {
        debugPrint('Attempting to sign up with email: $email');
      }

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final user = _createUserFromSupabase(response.user!);
        await _userRepository.saveUser(user);

        // Criar perfil no Supabase
        await _createUserProfile(response.user!.id, email);

        return user;
      }

      if (response.session != null && response.user != null) {
        final user = _createUserFromSupabase(response.user!);
        await _userRepository.saveUser(user);
        await _createUserProfile(response.user!.id, email);
        return user;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing up: $e');
      }
      rethrow;
    }
  }

  Future<void> _createUserProfile(String userId, String email) async {
    try {
      await _supabase.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'name': email.split('@').first,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user profile: $e');
      }
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Para web: usar callback local
      // Para mobile: usar fluxo OAuth nativo do Supabase
      final redirectUrl = kIsWeb
          ? 'https://nutrivisionh.netlify.app/auth-callback'
          : 'nutrivision-app://callback';

      if (kDebugMode) {
        debugPrint('🔐 Iniciando login com Google...');
        debugPrint('🔐 Redirect URL: $redirectUrl');
        debugPrint('🔐 kIsWeb: $kIsWeb');
      }

      // Para mobile, usamos o fluxo nativo que retorna via deep link
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (kDebugMode) {
        debugPrint('✅ signInWithOAuth chamado com sucesso');
      }
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Error signing in with Google: $e');
        debugPrint('❌ Stack trace: $stackTrace');
        debugPrint('❌ Error type: ${e.runtimeType}');
      }
      return false;
    }
  }

  /// Verifica se há sessão ativa (usado após OAuth callback)
  Future<app.User?> checkAuthSession() async {
    try {
      // Aguarda o Supabase processar o callback
      await Future.delayed(const Duration(milliseconds: 800));

      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (kDebugMode) {
        debugPrint('🔍 Verificando sessão...');
        debugPrint('🔍 Session: ${session != null}');
        debugPrint('🔍 User: ${user?.email}');
      }

      if (session != null && user != null) {
        final appUser = _createUserFromSupabase(user);
        await _userRepository.saveUser(appUser);
        return appUser;
      }

      // Tenta refresh como fallback
      await _supabase.auth.refreshSession();
      final refreshedSession = _supabase.auth.currentSession;
      final refreshedUser = _supabase.auth.currentUser;

      if (refreshedSession != null && refreshedUser != null) {
        final appUser = _createUserFromSupabase(refreshedUser);
        await _userRepository.saveUser(appUser);
        return appUser;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao verificar sessão: $e');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      _userRepository.clearUser();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SignOut error: $e');
      }
      _userRepository.clearUser();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResetPassword error: $e');
      }
      rethrow;
    }
  }

  app.User? getCurrentUser() {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      return _createUserFromSupabase(currentUser);
    }
    return _userRepository.getUser();
  }

  bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  app.User _createUserFromSupabase(User supabaseUser) {
    return app.User(
      id: supabaseUser.id,
      name: supabaseUser.userMetadata?['name'] ??
          supabaseUser.email?.split('@').first ??
          'Usuário',
      email: supabaseUser.email,
      photoUrl: supabaseUser.userMetadata?['avatar_url'],
      weight: 0,
      height: 0,
      age: 0,
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
  }
}
