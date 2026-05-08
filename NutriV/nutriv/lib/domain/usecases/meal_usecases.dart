import '../entities/meal.dart';
import '../../data/repositories/sync_meal_repository.dart';

class GetMealsByDateUseCase {
  final SyncMealRepository _repository;

  GetMealsByDateUseCase(this._repository);

  Future<List<Meal>> call(DateTime date) async {
    return await _repository.getMealsByDate(date);
  }
}

class AddMealUseCase {
  final SyncMealRepository _repository;

  AddMealUseCase(this._repository);

  Future<void> call(Meal meal) async {
    await _repository.saveMeal(meal);
  }
}

class UpdateMealUseCase {
  final SyncMealRepository _repository;

  UpdateMealUseCase(this._repository);

  Future<void> call(Meal meal) async {
    await _repository.updateMeal(meal);
  }
}

class DeleteMealUseCase {
  final SyncMealRepository _repository;

  DeleteMealUseCase(this._repository);

  Future<void> call(String mealId) async {
    await _repository.deleteMeal(mealId);
  }
}

class GetTodayMealsUseCase {
  final SyncMealRepository _repository;

  GetTodayMealsUseCase(this._repository);

  Future<List<Meal>> call() async {
    return await _repository.getMealsByDate(DateTime.now());
  }
}