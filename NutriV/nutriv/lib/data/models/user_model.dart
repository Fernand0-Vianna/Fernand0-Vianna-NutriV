import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.weight,
    required super.height,
    required super.age,
    required super.isMale,
    required super.activityLevel,
    required super.goal,
    required super.calorieGoal,
    required super.proteinGoal,
    required super.carbsGoal,
    required super.fatGoal,
    required super.waterGoal,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      isMale: json['isMale'] as bool,
      activityLevel: json['activityLevel'] as int,
      goal: json['goal'] as String,
      calorieGoal: (json['calorieGoal'] as num).toDouble(),
      proteinGoal: (json['proteinGoal'] as num).toDouble(),
      carbsGoal: (json['carbsGoal'] as num).toDouble(),
      fatGoal: (json['fatGoal'] as num).toDouble(),
      waterGoal: (json['waterGoal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'isMale': isMale,
      'activityLevel': activityLevel,
      'goal': goal,
      'calorieGoal': calorieGoal,
      'proteinGoal': proteinGoal,
      'carbsGoal': carbsGoal,
      'fatGoal': fatGoal,
      'waterGoal': waterGoal,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      weight: user.weight,
      height: user.height,
      age: user.age,
      isMale: user.isMale,
      activityLevel: user.activityLevel,
      goal: user.goal,
      calorieGoal: user.calorieGoal,
      proteinGoal: user.proteinGoal,
      carbsGoal: user.carbsGoal,
      fatGoal: user.fatGoal,
      waterGoal: user.waterGoal,
      createdAt: user.createdAt,
    );
  }
}
