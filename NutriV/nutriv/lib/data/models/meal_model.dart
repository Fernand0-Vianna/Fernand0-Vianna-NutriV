import '../../domain/entities/meal.dart';
import '../../domain/entities/food_item.dart';
import 'food_item_model.dart';

class MealModel extends Meal {
  const MealModel({
    required super.id,
    required super.name,
    required super.dateTime,
    required super.mealType,
    required super.foods,
    super.notes,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    final foodsList =
        (json['foods'] as List<dynamic>?)
            ?.map((f) => MealFoodModel.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [];

    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      mealType: json['mealType'] as String,
      foods: foodsList,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'mealType': mealType,
      'foods': foods
          .map(
            (f) => {
              'id': f.id,
              'food': FoodItemModel.fromEntity(f.food).toJson(),
              'quantity': f.quantity,
            },
          )
          .toList(),
      'notes': notes,
    };
  }

  factory MealModel.fromEntity(Meal meal) {
    return MealModel(
      id: meal.id,
      name: meal.name,
      dateTime: meal.dateTime,
      mealType: meal.mealType,
      foods: meal.foods,
      notes: meal.notes,
    );
  }
}

class MealFoodModel extends MealFood {
  const MealFoodModel({
    required super.id,
    required super.food,
    required super.quantity,
  });

  factory MealFoodModel.fromJson(Map<String, dynamic> json) {
    return MealFoodModel(
      id: json['id'] as String,
      food: FoodItemModel.fromJson(json['food'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toDouble(),
    );
  }

  factory MealFoodModel.fromEntity(MealFood mealFood) {
    return MealFoodModel(
      id: mealFood.id,
      food: mealFood.food,
      quantity: mealFood.quantity,
    );
  }
}
