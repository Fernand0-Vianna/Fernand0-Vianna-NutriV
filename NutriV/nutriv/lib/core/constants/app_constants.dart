class ApiConstants {
  static const String geminiApiKey = 'AIzaSyDFFfX3jrt4Ha2OAndYK88nbvEloqymjx4';
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String modelName = 'gemini-2.0-flash';

  static const String openaiApiKey =
      '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';
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
}

class AppConstants {
  static const String appName = 'NutriV';
  static const String dbName = 'nutriv.db';
  static const int dbVersion = 1;

  static const double defaultCalorieGoal = 2000.0;
  static const double defaultProteinGoal = 150.0;
  static const double defaultCarbsGoal = 250.0;
  static const double defaultFatGoal = 65.0;
  static const double defaultWaterGoal = 2000.0;

  static const List<String> mealTypes = [
    'Café da manhã',
    'Almoço',
    'Jantar',
    'Lanche',
  ];
}

class StorageKeys {
  static const String userProfile = 'user_profile';
  static const String dailyGoals = 'daily_goals';
  static const String themeMode = 'theme_mode';
  static const String onboardingComplete = 'onboarding_complete';
}
