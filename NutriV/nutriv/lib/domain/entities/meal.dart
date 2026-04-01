import 'package:equatable/equatable.dart';
import 'food_item.dart';

class Meal extends Equatable {
  final String id;
  final String name;
  final DateTime dateTime;
  final String mealType;
  final List<MealFood> foods;
  final String? notes;

  const Meal({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.mealType,
    required this.foods,
    this.notes,
  });

  double get totalCalories => foods.fold(0, (sum, f) => sum + f.totalCalories);
  double get totalProtein => foods.fold(0, (sum, f) => sum + f.totalProtein);
  double get totalCarbs => foods.fold(0, (sum, f) => sum + f.totalCarbs);
  double get totalFat => foods.fold(0, (sum, f) => sum + f.totalFat);

  Meal copyWith({
    String? id,
    String? name,
    DateTime? dateTime,
    String? mealType,
    List<MealFood>? foods,
    String? notes,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      mealType: mealType ?? this.mealType,
      foods: foods ?? this.foods,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, name, dateTime, mealType, foods, notes];
}

class MealFood extends Equatable {
  final String id;
  final FoodItem food;
  final double quantity;

  const MealFood({
    required this.id,
    required this.food,
    required this.quantity,
  });

  double get totalCalories => (food.calories / food.portion) * quantity;
  double get totalProtein => (food.protein / food.portion) * quantity;
  double get totalCarbs => (food.carbs / food.portion) * quantity;
  double get totalFat => (food.fat / food.portion) * quantity;

  MealFood copyWith({String? id, FoodItem? food, double? quantity}) {
    return MealFood(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, food, quantity];
}
