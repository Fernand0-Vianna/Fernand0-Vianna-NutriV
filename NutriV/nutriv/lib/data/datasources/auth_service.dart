import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import '../../domain/entities/user.dart' as app;
import '../repositories/user_repository.dart';
import '../../core/services/logging_service.dart';
import '../../core/utils/helpers.dart';

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
        LoggingService.error('AuthService', 'signInWithEmail', e);
      }
      rethrow;
    }
  }

  Future<app.User?> signUpWithEmail(String email, String password) async {
    try {
      if (kDebugMode) {
        LoggingService.auth('Attempting to sign up with email: $email');
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
        LoggingService.error('AuthService', 'signUpWithEmail', e);
      }
      rethrow;
    }
  }

  Future<void> _createUserProfile(String userId, String email) async {
    try {
      final name = email.split('@').first;
      
      // Valores padrão razoáveis
      const defaultWeight = 70.0;
      const defaultHeight = 170.0;
      const defaultAge = 30;
      const defaultActivity = 'moderate';
      const defaultGoal = 'maintain';
      const defaultCalorieGoal = 2000;
      const defaultProteinGoal = 150;
      const defaultCarbsGoal = 200;
      const defaultFatGoal = 65;
      const defaultWaterGoal = 2500;
      
      await _supabase.from('user_profiles').upsert({
        'id': userId,
        'email': email,
        'name': name,
        'current_weight_kg': defaultWeight,
        'height_cm': defaultHeight,
        'birth_date': DateTime.now().subtract(Duration(days: defaultAge * 365)).toIso8601String().split('T')[0],
        'gender': 'male',
        'activity_level': defaultActivity,
        'goal_type': defaultGoal,
        'target_weight_kg': defaultWeight,
        'weekly_goal_kg': 0.5,
        'bmr_calories': 1700,
        'tdee_calories': 2600,
        'daily_calories_target': defaultCalorieGoal,
        'protein_target_g': defaultProteinGoal,
        'carbs_target_g': defaultCarbsGoal,
        'fat_target_g': defaultFatGoal,
        'water_target_ml': defaultWaterGoal,
        'daily_steps_target': 10000,
        'measurement_unit': 'metric',
        'language': 'pt-BR',
        'timezone': 'America/Sao_Paulo',
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
      
      LoggingService.auth('Perfil criado no Supabase para: $email');
    } catch (e) {
      LoggingService.error('AuthService', 'createUserProfile', e);
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
        LoggingService.auth('Iniciando login com Google...');
        LoggingService.auth('Redirect URL: $redirectUrl');
        LoggingService.auth('kIsWeb: $kIsWeb');
      }

      // Para mobile, usamos o fluxo nativo que retorna via deep link
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'nutrivision-app://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (kDebugMode) {
        LoggingService.auth('signInWithOAuth chamado com sucesso');
      }
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        LoggingService.error('AuthService', 'signInWithGoogle', e);
        LoggingService.error('AuthService', 'signInWithGoogle stack', stackTrace);
        LoggingService.error('AuthService', 'signInWithGoogle type', e.runtimeType);
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
        LoggingService.auth('Verificando sessão...');
        LoggingService.auth('Session: ${session != null}');
        LoggingService.auth('User: ${user?.email}');
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
        LoggingService.error('AuthService', 'checkAuthSession', e);
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
        LoggingService.error('AuthService', 'signOut', e);
      }
      _userRepository.clearUser();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (kDebugMode) {
        LoggingService.error('AuthService', 'resetPassword', e);
      }
      rethrow;
    }
  }

  app.User? getCurrentUser() {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      // Primeiro tenta buscar perfil do Supabase
      return _createUserFromSupabase(currentUser);
    }
    // Fallback para dados locais
    return _userRepository.getUser();
  }

  Future<app.User?> fetchUserProfileFromSupabase() async {
    try {
      final supabaseUser = _supabase.auth.currentUser;
      if (supabaseUser == null) {
        LoggingService.error('AuthService', 'fetchUserProfileFromSupabase', 'currentUser é null');
        return null;
      }
      LoggingService.auth('fetchUserProfile: userId = ${supabaseUser.id}');

      // Buscar perfil completo do Supabase
      final profile = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (profile != null) {
        LoggingService.auth('fetchUserProfile: perfil encontrado no banco');
        
        // Calcular idade a partir da data de nascimento
        int age = 30;
        if (profile['birth_date'] != null) {
          final birthDate = DateTime.parse(profile['birth_date'] as String);
          age = DateTime.now().difference(birthDate).inDays ~/ 365;
        }
        
        // Mapear activity_level de texto para número
        int activityLevel = 2; // moderate
        final activityText = profile['activity_level'] as String?;
        switch (activityText) {
          case 'sedentary': activityLevel = 0; break;
          case 'light': activityLevel = 1; break;
          case 'moderate': activityLevel = 2; break;
          case 'active': activityLevel = 3; break;
          case 'very_active': activityLevel = 4; break;
        }
        
        // Mapear gender para bool
        final isMale = (profile['gender'] as String?) == 'male';
        
        return app.User(
          id: profile['id'] as String,
          name: profile['name'] as String? ?? 'Usuário',
          email: profile['email'] as String?,
          photoUrl: profile['avatar_url'] as String?,
          weight: (profile['current_weight_kg'] as num?)?.toDouble() ?? 70,
          height: (profile['height_cm'] as num?)?.toDouble() ?? 170,
          age: age,
          isMale: isMale,
          activityLevel: activityLevel,
          goal: profile['goal_type'] as String? ?? 'maintain',
          calorieGoal: (profile['daily_calories_target'] as num?)?.toDouble() ?? 2000,
          proteinGoal: (profile['protein_target_g'] as num?)?.toDouble() ?? 150,
          carbsGoal: (profile['carbs_target_g'] as num?)?.toDouble() ?? 200,
          fatGoal: (profile['fat_target_g'] as num?)?.toDouble() ?? 65,
          waterGoal: (profile['water_target_ml'] as num?)?.toDouble() ?? 2500,
          createdAt: profile['created_at'] != null 
              ? DateTime.parse(profile['created_at'] as String) 
              : DateTime.now(),
        );
      }
      
      LoggingService.auth('fetchUserProfile: perfil não encontrado, criando novo...');
      // Se não tem perfil, cria um novo com valores padrão
      final newUser = await _createOrUpdateProfile(supabaseUser);
      return newUser;
    } catch (e) {
      LoggingService.error('AuthService', 'fetchUserProfileFromSupabase', e);
      return null;
    }
  }
  
  Future<app.User?> _createOrUpdateProfile(User supabaseUser) async {
    try {
      final name = supabaseUser.userMetadata?['name'] ?? 
        supabaseUser.email?.split('@').first ?? 
        'Usuário';
      final avatarUrl = supabaseUser.userMetadata?['avatar_url'] as String?;
      
      // Usar valores padrão razoáveis
      const defaultWeight = 70.0;
      const defaultHeight = 170.0;
      const defaultAge = 30;
      const defaultIsMale = true;
      const defaultActivityLevel = 1; // moderate
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
      
      await _supabase.from('user_profiles').upsert({
        'id': supabaseUser.id,
        'email': supabaseUser.email,
        'name': name,
        'avatar_url': avatarUrl,
        'current_weight_kg': defaultWeight,
        'height_cm': defaultHeight,
        'birth_date': DateTime.now().subtract(Duration(days: defaultAge * 365)).toIso8601String().split('T')[0],
        'gender': defaultIsMale ? 'male' : 'female',
        'activity_level': 'moderate',
        'goal_type': defaultGoal,
        'target_weight_kg': defaultWeight,
        'weekly_goal_kg': 0.5,
        'bmr_calories': bmr,
        'tdee_calories': tdee,
        'daily_calories_target': calorieGoal,
        'protein_target_g': proteinGoal,
        'carbs_target_g': carbsGoal,
        'fat_target_g': fatGoal,
        'water_target_ml': waterGoal,
        'daily_steps_target': 10000,
        'measurement_unit': 'metric',
        'language': 'pt-BR',
        'timezone': 'America/Sao_Paulo',
      }, onConflict: 'id');
      
      LoggingService.auth('Perfil criado no Supabase com metas calculadas');
      
      return app.User(
        id: supabaseUser.id,
        name: name,
        email: supabaseUser.email,
        photoUrl: avatarUrl,
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
    } catch (e) {
      LoggingService.error('AuthService', '_createOrUpdateProfile', e);
      return null;
    }
  }

  bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  app.User _createUserFromSupabase(User supabaseUser) {
    // Buscar perfil do usuário no Supabase se existir
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

  Future<void> createProfileIfNotExists(User supabaseUser) async {
    try {
      // Verificar se perfil já existe
      final existing = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', supabaseUser.id)
          .maybeSingle();

      if (existing == null) {
        await _supabase.from('user_profiles').insert({
          'id': supabaseUser.id,
          'email': supabaseUser.email,
          'name': supabaseUser.userMetadata?['name'] ??
              supabaseUser.email?.split('@').first ??
              'Usuário',
          'avatar_url': supabaseUser.userMetadata?['avatar_url'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        LoggingService.error('AuthService', 'createProfileIfNotExists', e);
      }
    }
  }
}
