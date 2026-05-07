import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/daily_log_model.dart';
import '../../domain/entities/daily_log.dart';
import '../database/database_helper.dart';

class LocalDataSource {
  final SharedPreferences _prefs;
  final DatabaseHelper _db;

  LocalDataSource(this._prefs, this._db);

  Future<void> saveUser(UserModel user) async {
    await _db.saveUserProfile({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photo_url': user.photoUrl,
      'weight': user.weight,
      'height': user.height,
      'age': user.age,
      'is_male': user.isMale ? 1 : 0,
      'activity_level': user.activityLevel,
      'goal': user.goal,
      'calorie_goal': user.calorieGoal,
      'protein_goal': user.proteinGoal,
      'carbs_goal': user.carbsGoal,
      'fat_goal': user.fatGoal,
      'water_goal': user.waterGoal,
      'created_at': user.createdAt.toIso8601String(),
    });

    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userData = _prefs.getString('user');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<UserModel?> getUserFromDb() async {
    final profile = await _db.getUserProfile();
    if (profile == null) return null;

    return UserModel(
      id: profile['id'] as String,
      name: profile['name'] as String,
      weight: (profile['weight'] as num).toDouble(),
      height: (profile['height'] as num).toDouble(),
      age: profile['age'] as int,
      isMale: (profile['is_male'] as int) == 1,
      activityLevel: profile['activity_level'] as int,
      goal: profile['goal'] as String,
      calorieGoal: (profile['calorie_goal'] as num).toDouble(),
      proteinGoal: (profile['protein_goal'] as num).toDouble(),
      carbsGoal: (profile['carbs_goal'] as num).toDouble(),
      fatGoal: (profile['fat_goal'] as num).toDouble(),
      waterGoal: (profile['water_goal'] as num).toDouble(),
      createdAt: DateTime.parse(profile['created_at'] as String),
    );
  }

  Future<void> deleteUser() async {
    await _prefs.remove('user');
    await _db.deleteUserProfile();
  }

  Future<void> saveDailyLog(DailyLogModel dailyLog) async {
    final dateStr = _formatDate(dailyLog.date);
    await _db.saveDailyLog({
      'id': dailyLog.id,
      'date': dateStr,
      'total_calories': dailyLog.totalCalories,
      'total_protein': dailyLog.totalProtein,
      'total_carbs': dailyLog.totalCarbs,
      'total_fat': dailyLog.totalFat,
      'water_intake': dailyLog.waterIntake,
      'calorie_goal': dailyLog.calorieGoal,
      'protein_goal': dailyLog.proteinGoal,
      'carbs_goal': dailyLog.carbsGoal,
      'fat_goal': dailyLog.fatGoal,
      'water_goal': dailyLog.waterGoal,
    });

    final logs = getDailyLogs();
    final index = logs.indexWhere((l) => _isSameDay(l.date, dailyLog.date));

    if (index >= 0) {
      logs[index] = dailyLog;
    } else {
      logs.add(dailyLog);
    }

    final logsJson =
        logs.map((l) => DailyLogModel.fromEntity(l).toJson()).toList();
    await _prefs.setString('daily_logs', jsonEncode(logsJson));
  }

  List<DailyLog> getDailyLogs() {
    final logsData = _prefs.getString('daily_logs');
    if (logsData != null) {
      final List<dynamic> decoded = jsonDecode(logsData);
      return decoded.map((l) => DailyLogModel.fromJson(l)).toList();
    }
    return [];
  }

  DailyLog? getDailyLogByDate(DateTime date) {
    final logs = getDailyLogs();
    for (var log in logs) {
      if (_isSameDay(log.date, date)) {
        return log;
      }
    }
    return null;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool('onboarding_complete', complete);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool('onboarding_complete') ?? false;
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }
}
