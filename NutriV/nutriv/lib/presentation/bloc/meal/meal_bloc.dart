import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/meal_repository.dart';
import 'meal_event.dart';
import 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final MealRepository _mealRepository;
  DateTime _currentDate = DateTime.now();

  MealBloc(this._mealRepository) : super(MealInitial()) {
    on<LoadMeals>(_onLoadMeals);
    on<AddMeal>(_onAddMeal);
    on<UpdateMeal>(_onUpdateMeal);
    on<DeleteMeal>(_onDeleteMeal);
    on<AddFoodToMeal>(_onAddFoodToMeal);
    on<RemoveFoodFromMeal>(_onRemoveFoodFromMeal);
  }

  void _onLoadMeals(LoadMeals event, Emitter<MealState> emit) {
    emit(MealLoading());
    _currentDate = event.date;
    try {
      final meals = _mealRepository.getMealsByDate(event.date);
      emit(MealLoaded(date: event.date, meals: meals));
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> _onAddMeal(AddMeal event, Emitter<MealState> emit) async {
    try {
      await _mealRepository.saveMeal(event.meal);
      final meals = _mealRepository.getMealsByDate(_currentDate);
      emit(MealLoaded(date: _currentDate, meals: meals));
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> _onUpdateMeal(UpdateMeal event, Emitter<MealState> emit) async {
    try {
      await _mealRepository.updateMeal(event.meal);
      final meals = _mealRepository.getMealsByDate(_currentDate);
      emit(MealLoaded(date: _currentDate, meals: meals));
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> _onDeleteMeal(DeleteMeal event, Emitter<MealState> emit) async {
    try {
      await _mealRepository.deleteMeal(event.mealId);
      final meals = _mealRepository.getMealsByDate(_currentDate);
      emit(MealLoaded(date: _currentDate, meals: meals));
    } catch (e) {
      emit(MealError(e.toString()));
    }
  }

  Future<void> _onAddFoodToMeal(
    AddFoodToMeal event,
    Emitter<MealState> emit,
  ) async {
    final currentState = state;
    if (currentState is MealLoaded) {
      try {
        final mealIndex = currentState.meals.indexWhere(
          (m) => m.id == event.mealId,
        );
        if (mealIndex >= 0) {
          final meal = currentState.meals[mealIndex];
          final updatedFoods = [...meal.foods, event.food];
          final updatedMeal = meal.copyWith(foods: updatedFoods);
          await _mealRepository.updateMeal(updatedMeal);

          final meals = _mealRepository.getMealsByDate(_currentDate);
          emit(MealLoaded(date: _currentDate, meals: meals));
        }
      } catch (e) {
        emit(MealError(e.toString()));
      }
    }
  }

  Future<void> _onRemoveFoodFromMeal(
    RemoveFoodFromMeal event,
    Emitter<MealState> emit,
  ) async {
    final currentState = state;
    if (currentState is MealLoaded) {
      try {
        final mealIndex = currentState.meals.indexWhere(
          (m) => m.id == event.mealId,
        );
        if (mealIndex >= 0) {
          final meal = currentState.meals[mealIndex];
          final updatedFoods = meal.foods
              .where((f) => f.id != event.foodId)
              .toList();
          final updatedMeal = meal.copyWith(foods: updatedFoods);
          await _mealRepository.updateMeal(updatedMeal);

          final meals = _mealRepository.getMealsByDate(_currentDate);
          emit(MealLoaded(date: _currentDate, meals: meals));
        }
      } catch (e) {
        emit(MealError(e.toString()));
      }
    }
  }
}
