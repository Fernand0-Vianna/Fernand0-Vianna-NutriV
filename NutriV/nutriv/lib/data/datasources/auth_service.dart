import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  Future<void> _createUserProfileIfNotExists(String userId, String? email) async {
    try {
      final existing = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      
      if (existing == null && email != null) {
        await _supabase.from('user_profiles').insert({
          'id': userId,
          'email': email,
          'name': email.split('@').first,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating user profile if not exists: $e');
      }
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      // Web: use OAuth redirect
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'https://nutrivisionh.netlify.app/auth-callback',
        );
        return true;
      }

      // Mobile (Android/iOS): use Google Sign In nativo
      // serverClientId é o Web Client ID do Google Cloud Console (client_type: 3)
      // necessário para autenticação com Supabase
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'openid', 'profile'],
        serverClientId:
            '510166294031-ehhl2r349bbd6n9q2pr22scqod2338hr.apps.googleusercontent.com',
      );

      // Sign out first to force account picker
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Google Auth: ID Token is null';
      }

      // Sign in to Supabase with Google ID Token
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user != null) {
        final user = _createUserFromSupabase(response.user!);
        await _userRepository.saveUser(user);
        
        // Criar perfil se não existir
        await _createUserProfileIfNotExists(response.user!.id, user.email);
        
        return true;
      }

      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error signing in with Google: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
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
      name:
          supabaseUser.userMetadata?['name'] ??
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
