import '../../domain/entities/user.dart';

class UserProfileModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime? birthDate;
  final String? gender;
  final double? heightCm;
  final double? currentWeightKg;
  final String? activityLevel;
  final String? goalType;
  final double? targetWeightKg;
  final double weeklyGoalKg;
  final double? bmrCalories;
  final double? tdeeCalories;
  final double dailyCaloriesTarget;
  final double proteinTargetG;
  final double carbsTargetG;
  final double fatTargetG;
  final double waterTargetMl;
  final int dailyStepsTarget;
  final String measurementUnit;
  final String language;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActiveAt;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    this.heightCm,
    this.currentWeightKg,
    this.activityLevel,
    this.goalType,
    this.targetWeightKg,
    this.weeklyGoalKg = 0.5,
    this.bmrCalories,
    this.tdeeCalories,
    this.dailyCaloriesTarget = 2000,
    this.proteinTargetG = 150,
    this.carbsTargetG = 200,
    this.fatTargetG = 65,
    this.waterTargetMl = 2500,
    this.dailyStepsTarget = 10000,
    this.measurementUnit = 'metric',
    this.language = 'pt-BR',
    this.timezone = 'America/Sao_Paulo',
    required this.createdAt,
    required this.updatedAt,
    this.lastActiveAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
      activityLevel: json['activity_level'] as String?,
      goalType: json['goal_type'] as String?,
      targetWeightKg: (json['target_weight_kg'] as num?)?.toDouble(),
      weeklyGoalKg: (json['weekly_goal_kg'] as num?)?.toDouble() ?? 0.5,
      bmrCalories: (json['bmr_calories'] as num?)?.toDouble(),
      tdeeCalories: (json['tdee_calories'] as num?)?.toDouble(),
      dailyCaloriesTarget:
          (json['daily_calories_target'] as num?)?.toDouble() ?? 2000,
      proteinTargetG: (json['protein_target_g'] as num?)?.toDouble() ?? 150,
      carbsTargetG: (json['carbs_target_g'] as num?)?.toDouble() ?? 200,
      fatTargetG: (json['fat_target_g'] as num?)?.toDouble() ?? 65,
      waterTargetMl: (json['water_target_ml'] as num?)?.toDouble() ?? 2500,
      dailyStepsTarget: (json['daily_steps_target'] as int?) ?? 10000,
      measurementUnit: json['measurement_unit'] as String? ?? 'metric',
      language: json['language'] as String? ?? 'pt-BR',
      timezone: json['timezone'] as String? ?? 'America/Sao_Paulo',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'birth_date': birthDate?.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'current_weight_kg': currentWeightKg,
      'activity_level': activityLevel,
      'goal_type': goalType,
      'target_weight_kg': targetWeightKg,
      'weekly_goal_kg': weeklyGoalKg,
      'bmr_calories': bmrCalories,
      'tdee_calories': tdeeCalories,
      'daily_calories_target': dailyCaloriesTarget,
      'protein_target_g': proteinTargetG,
      'carbs_target_g': carbsTargetG,
      'fat_target_g': fatTargetG,
      'water_target_ml': waterTargetMl,
      'daily_steps_target': dailyStepsTarget,
      'measurement_unit': measurementUnit,
      'language': language,
      'timezone': timezone,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      photoUrl: avatarUrl,
      weight: currentWeightKg ?? 70,
      height: heightCm ?? 170,
      age: birthDate != null
          ? DateTime.now().difference(birthDate!).inDays ~/ 365
          : 25,
      isMale: gender == 'male',
      activityLevel: _activityLevelToInt(),
      goal: goalType ?? 'maintain',
      calorieGoal: dailyCaloriesTarget,
      proteinGoal: proteinTargetG,
      carbsGoal: carbsTargetG,
      fatGoal: fatTargetG,
      waterGoal: waterTargetMl,
      createdAt: createdAt,
    );
  }

  int _activityLevelToInt() {
    switch (activityLevel) {
      case 'sedentary':
        return 0;
      case 'light':
        return 1;
      case 'moderate':
        return 2;
      case 'active':
        return 3;
      case 'very_active':
        return 4;
      default:
        return 2;
    }
  }

  UserProfileModel copyWith({
    String? name,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    String? activityLevel,
    String? goalType,
    double? targetWeightKg,
    double? weeklyGoalKg,
    double? bmrCalories,
    double? tdeeCalories,
    double? dailyCaloriesTarget,
    double? proteinTargetG,
    double? carbsTargetG,
    double? fatTargetG,
    double? waterTargetMl,
    int? dailyStepsTarget,
    String? measurementUnit,
    String? language,
    String? timezone,
  }) {
    return UserProfileModel(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goalType: goalType ?? this.goalType,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      weeklyGoalKg: weeklyGoalKg ?? this.weeklyGoalKg,
      bmrCalories: bmrCalories ?? this.bmrCalories,
      tdeeCalories: tdeeCalories ?? this.tdeeCalories,
      dailyCaloriesTarget: dailyCaloriesTarget ?? this.dailyCaloriesTarget,
      proteinTargetG: proteinTargetG ?? this.proteinTargetG,
      carbsTargetG: carbsTargetG ?? this.carbsTargetG,
      fatTargetG: fatTargetG ?? this.fatTargetG,
      waterTargetMl: waterTargetMl ?? this.waterTargetMl,
      dailyStepsTarget: dailyStepsTarget ?? this.dailyStepsTarget,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActiveAt: lastActiveAt,
    );
  }
}
