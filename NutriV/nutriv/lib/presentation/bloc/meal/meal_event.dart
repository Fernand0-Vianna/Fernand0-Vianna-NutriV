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

  const AddMeal(this.meal);

  @override
  List<Object?> get props => [meal];
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

class RemoveFoodFromMeal extends MealEvent {
  final String mealId;
  final String foodId;

  const RemoveFoodFromMeal({required this.mealId, required this.foodId});

  @override
  List<Object?> get props => [mealId, foodId];
}
