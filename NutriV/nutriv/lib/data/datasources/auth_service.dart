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

      if (kDebugMode) {
        debugPrint('Sign up response: ${response.user}');
        debugPrint('Session: ${response.session}');
        debugPrint('User metadata: ${response.user?.userMetadata}');
      }

      if (response.user != null) {
        final user = _createUserFromSupabase(response.user!);
        await _userRepository.saveUser(user);
        return user;
      }

      if (response.session != null) {
        final user = _createUserFromSupabase(response.user!);
        await _userRepository.saveUser(user);
        return user;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing up with email: $e');
      }
      rethrow;
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
      final googleSignIn = GoogleSignIn(scopes: ['email', 'openid', 'profile']);

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
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error signing in with Google: $e');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _userRepository.clearUser();
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
