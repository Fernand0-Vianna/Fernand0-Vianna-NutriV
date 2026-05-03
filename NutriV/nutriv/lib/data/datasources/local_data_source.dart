import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/daily_log_model.dart';
import '../../domain/entities/daily_log.dart';

class LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSource(this._prefs);

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  UserModel? getUser() {
    final userData = _prefs.getString('user');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _prefs.remove('user');
  }

  Future<void> saveDailyLog(DailyLogModel dailyLog) async {
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
