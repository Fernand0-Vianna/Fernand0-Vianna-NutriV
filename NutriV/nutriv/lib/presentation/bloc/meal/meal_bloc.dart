import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/sync_meal_repository.dart';
import '../../../domain/entities/meal.dart';
import 'meal_event.dart';
import 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final SyncMealRepository _mealRepository;
  DateTime _currentDate = DateTime.now();

  MealBloc(this._mealRepository) : super(MealInitial()) {
    on<LoadMeals>(_onLoadMeals);
    on<AddMeal>(_onAddMeal);
    on<UpdateMeal>(_onUpdateMeal);
    on<DeleteMeal>(_onDeleteMeal);
    on<AddFoodToMeal>(_onAddFoodToMeal);
    on<RemoveFoodFromMeal>(_onRemoveFoodFromMeal);
    on<AddMealFood>(_onAddMealFood);
  }

  Future<void> _onLoadMeals(LoadMeals event, Emitter<MealState> emit) async {
    emit(MealLoading());
    _currentDate = event.date;
    try {
      final meals = _mealRepository.getMealsByDate(event.date);
      emit(MealLoaded(date: event.date, meals: meals));
    } catch (e) {
      debugPrint('MealBloc LoadMeals error: $e');
      emit(MealError('Erro ao carregar refeições'));
    }
  }

  Future<void> _onAddMeal(AddMeal event, Emitter<MealState> emit) async {
    try {
      await _mealRepository.saveMeal(event.meal);
      final meals = _mealRepository.getMealsByDate(_currentDate);
      emit(MealLoaded(date: _currentDate, meals: meals));
    } catch (e) {
      debugPrint('MealBloc AddMeal error: $e');
      emit(MealError('Erro ao adicionar refeição'));
    }
  }

  Future<void> _onUpdateMeal(UpdateMeal event, Emitter<MealState> emit) async {
    try {
      await _mealRepository.updateMeal(event.meal);
      final meals = _mealRepository.getMealsByDate(_currentDate);
      emit(MealLoaded(date: _currentDate, meals: meals));
    } catch (e) {
      debugPrint('MealBloc UpdateMeal error: $e');
      emit(MealError('Erro ao atualizar refeição'));
    }
  }

  Future<void> _onDeleteMeal(DeleteMeal event, Emitter<MealState> emit) async {
    try {
      await _mealRepository.deleteMeal(event.mealId);
      final meals = _mealRepository.getMealsByDate(_currentDate);
      emit(MealLoaded(date: _currentDate, meals: meals));
    } catch (e) {
      debugPrint('MealBloc DeleteMeal error: $e');
      emit(MealError('Erro ao excluir refeição'));
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
        debugPrint('MealBloc AddFoodToMeal error: $e');
        emit(MealError('Erro ao adicionar alimento'));
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
        debugPrint('MealBloc RemoveFoodFromMeal error: $e');
        emit(MealError('Erro ao remover alimento'));
      }
    }
  }

  Future<void> _onAddMealFood(
    AddMealFood event,
    Emitter<MealState> emit,
  ) async {
    try {
      final existingMeals = _mealRepository.getMealsByDate(event.date);
      final mealTypeKey = event.mealType;

      Meal meal;
      try {
        meal = existingMeals.firstWhere((m) => m.mealType == mealTypeKey);
      } catch (_) {
        meal = Meal(
          id: '${event.date.toIso8601String()}_$mealTypeKey',
          name: _getMealName(mealTypeKey),
          mealType: mealTypeKey,
          dateTime: event.date,
          foods: [],
        );
      }

      final updatedFoods = [...meal.foods, event.food];
      final updatedMeal = meal.copyWith(foods: updatedFoods);

      await _mealRepository.saveMeal(updatedMeal);

      final meals = _mealRepository.getMealsByDate(event.date);
      emit(MealLoaded(date: event.date, meals: meals));
    } catch (e) {
      debugPrint('MealBloc AddMealFood error: $e');
      emit(MealError('Erro ao adicionar alimento à refeição'));
    }
  }

  String _getMealName(String mealType) {
    switch (mealType) {
      case 'café da manhã':
        return 'Café da Manhã';
      case 'almoço':
        return 'Almoço';
      case 'jantar':
        return 'Jantar';
      case 'lanche':
        return 'Lanche';
      default:
        return 'Refeição';
    }
  }
}
