import 'package:equatable/equatable.dart';
import '../../../domain/entities/meal.dart';

abstract class MealEvent extends Equatable {
  const MealEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeals extends MealEvent {
  final DateTime date;

  const LoadMeals(this.date);

  @override
  List<Object?> get props => [date];
}

class AddMeal extends MealEvent {
  final Meal meal;
  final String inputMethod;

  const AddMeal(this.meal, {this.inputMethod = 'manual'});

  @override
  List<Object?> get props => [meal, inputMethod];
}

class UpdateMeal extends MealEvent {
  final Meal meal;

  const UpdateMeal(this.meal);

  @override
  List<Object?> get props => [meal];
}

class DeleteMeal extends MealEvent {
  final String mealId;

  const DeleteMeal(this.mealId);

  @override
  List<Object?> get props => [mealId];
}

class AddFoodToMeal extends MealEvent {
  final String mealId;
  final MealFood food;

  const AddFoodToMeal({required this.mealId, required this.food});

  @override
  List<Object?> get props => [mealId, food];
}

class SyncMeals extends MealEvent {
  final DateTime date;

  const SyncMeals(this.date);

  @override
  List<Object?> get props => [date];
}

class RemoveFoodFromMeal extends MealEvent {
  final String mealId;
  final String foodId;

  const RemoveFoodFromMeal({required this.mealId, required this.foodId});

  @override
  List<Object?> get props => [mealId, foodId];
}

class AddMealFood extends MealEvent {
  final String mealType;
  final MealFood food;
  final double quantity;
  final DateTime date;
  final String inputMethod;

  const AddMealFood({
    required this.mealType,
    required this.food,
    required this.quantity,
    required this.date,
    this.inputMethod = 'manual',
  });

  @override
  List<Object?> get props => [mealType, food, quantity, date, inputMethod];
}
