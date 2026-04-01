import 'package:equatable/equatable.dart';
import '../../../domain/entities/meal.dart';

abstract class MealState extends Equatable {
  const MealState();

  @override
  List<Object?> get props => [];
}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealLoaded extends MealState {
  final DateTime date;
  final List<Meal> meals;

  const MealLoaded({required this.date, required this.meals});

  double get totalCalories => meals.fold(0, (sum, m) => sum + m.totalCalories);
  double get totalProtein => meals.fold(0, (sum, m) => sum + m.totalProtein);
  double get totalCarbs => meals.fold(0, (sum, m) => sum + m.totalCarbs);
  double get totalFat => meals.fold(0, (sum, m) => sum + m.totalFat);

  List<Meal> getMealsByType(String mealType) {
    return meals.where((m) => m.mealType == mealType).toList();
  }

  @override
  List<Object?> get props => [date, meals];
}

class MealError extends MealState {
  final String message;

  const MealError(this.message);

  @override
  List<Object?> get props => [message];
}
