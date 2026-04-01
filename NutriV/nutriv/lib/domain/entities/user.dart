import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final double weight;
  final double height;
  final int age;
  final bool isMale;
  final int activityLevel;
  final String goal;
  final double calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double waterGoal;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.isMale,
    required this.activityLevel,
    required this.goal,
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    required this.waterGoal,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    double? weight,
    double? height,
    int? age,
    bool? isMale,
    int? activityLevel,
    String? goal,
    double? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
    double? waterGoal,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      isMale: isMale ?? this.isMale,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbsGoal: carbsGoal ?? this.carbsGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    weight,
    height,
    age,
    isMale,
    activityLevel,
    goal,
    calorieGoal,
    proteinGoal,
    carbsGoal,
    fatGoal,
    waterGoal,
    createdAt,
  ];
}
