import '../../domain/entities/daily_log.dart';

class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.date,
    required super.totalCalories,
    required super.totalProtein,
    required super.totalCarbs,
    required super.totalFat,
    required super.waterIntake,
    required super.calorieGoal,
    required super.proteinGoal,
    required super.carbsGoal,
    required super.fatGoal,
    required super.waterGoal,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      waterIntake: (json['waterIntake'] as num).toDouble(),
      calorieGoal: (json['calorieGoal'] as num).toDouble(),
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      carbsGoal: (json['carbsGoal'] as num).toDouble(),
      fatGoal: (json['fatGoal'] as num).toDouble(),
      waterGoal: (json['waterGoal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'waterIntake': waterIntake,
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'waterGoal': waterGoal,
    };
  }

  factory DailyLogModel.fromEntity(DailyLog dailyLog) {
    return DailyLogModel(
      id: dailyLog.id,
      date: dailyLog.date,
      totalCalories: dailyLog.totalCalories,
      totalProtein: dailyLog.totalProtein,
      totalCarbs: dailyLog.totalCarbs,
      totalFat: dailyLog.totalFat,
      waterIntake: dailyLog.waterIntake,
      calorieGoal: dailyLog.calorieGoal,
      proteinGoal: dailyLog.proteinGoal,
      carbsGoal: dailyLog.carbsGoal,
      fatGoal: dailyLog.fatGoal,
      waterGoal: dailyLog.waterGoal,
    );
  }
}
