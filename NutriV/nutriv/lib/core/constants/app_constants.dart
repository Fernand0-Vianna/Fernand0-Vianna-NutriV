import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
          '[NutriV] GEMINI_API_KEY não configurada no arquivo .env');
    }
    return key;
  }

  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String modelName = 'gemini-2.5-flash';

  static String get openaiApiKey {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
          '[NutriV] OPENAI_API_KEY não configurada no arquivo .env');
    }
    return key;
  }

  static const String openaiBaseUrl = 'https://api.openai.com/v1';
}

class AppConstants {
  static const String appName = 'Nutrivision';
  static const String dbName = 'nutriv.db';
  static const int dbVersion = 1;

  static const double defaultCalorieGoal = 2000.0;
  static const double defaultProteinGoal = 150.0;
  static const double defaultCarbsGoal = 250.0;
  static const double defaultFatGoal = 65.0;
  static const double defaultWaterGoal = 2000.0;
}

enum MealType {
  breakfast('Café da manhã', 'café da manhã', 'breakfast'),
  lunch('Almoço', 'almoço', 'lunch'),
  dinner('Jantar', 'jantar', 'dinner'),
  snack('Lanche', 'lanche', 'snack');

  final String displayName;
  final String key;
  final String dbValue;
  const MealType(this.displayName, this.key, this.dbValue);

  static MealType fromKey(String key) {
    return MealType.values.firstWhere(
      (m) => m.key == key.toLowerCase(),
      orElse: () => MealType.breakfast,
    );
  }

  static MealType fromDbValue(String dbValue) {
    return MealType.values.firstWhere(
      (m) => m.dbValue == dbValue,
      orElse: () => MealType.breakfast,
    );
  }

  static List<String> get displayNames =>
      MealType.values.map((m) => m.displayName).toList();

  static List<String> get keys => MealType.values.map((m) => m.key).toList();
}

class StorageKeys {
  static const String userProfile = 'user_profile';
  static const String dailyGoals = 'daily_goals';
  static const String themeMode = 'theme_mode';
  static const String onboardingComplete = 'onboarding_complete';
}
