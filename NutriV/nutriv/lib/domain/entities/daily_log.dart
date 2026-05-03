import 'package:equatable/equatable.dart';

class DailyLog extends Equatable {
  final String id;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double waterIntake;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double waterGoal;

  const DailyLog({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.waterIntake,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
  });

  double get calorieProgress => totalCalories / calorieGoal;
  double get proteinProgress => totalProtein / proteinGoal;
  double get carbsProgress => totalCarbs / carbsGoal;
  double get fatProgress => totalFat / fatGoal;
  double get waterProgress => waterIntake / waterGoal;

  DailyLog copyWith({
    String? id,
    DateTime? date,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? waterIntake,
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    double? waterGoal,
  }) {
    return DailyLog(
      id: id ?? this.id,
      date: date ?? this.date,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      waterIntake: waterIntake ?? this.waterIntake,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        totalCalories,
        totalProtein,
        totalCarbs,
        totalFat,
        waterIntake,
        calorieGoal,
        proteinGoal,
        carbsGoal,
        fatGoal,
        waterGoal,
      ];
}
