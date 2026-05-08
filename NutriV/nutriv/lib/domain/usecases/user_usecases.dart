import '../entities/user.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/datasources/auth_service.dart';
import '../../core/utils/helpers.dart';

class GetCurrentUserUseCase {
  final UserRepository _repository;

  GetCurrentUserUseCase(this._repository);

  User? call() {
    return _repository.getUser();
  }
}

class SaveUserUseCase {
  final UserRepository _repository;

  SaveUserUseCase(this._repository);

  Future<void> call(User user) async {
    await _repository.saveUser(user);
  }
}

class UpdateUserProfileUseCase {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<void> call({
    required User user,
    double? weight,
    double? height,
    int? age,
    bool? isMale,
    int? activityLevel,
    String? goal,
  }) async {
    final bmr = NutritionUtils.calculateBMR(
      weight: weight ?? user.weight,
      height: height ?? user.height,
      age: age ?? user.age,
      isMale: isMale ?? user.isMale,
    );
    final tdee = NutritionUtils.calculateTDEE(bmr, activityLevel ?? user.activityLevel);
    final goalCalories = NutritionUtils.calculateGoalCalories(tdee, goal ?? user.goal);
    final proteinGoal = (goal ?? user.goal) == 'lose' ? (weight ?? user.weight) * 2.0 : (weight ?? user.weight) * 1.6;
    final carbsGoal = goalCalories * 0.4 / 4;
    final fatGoal = goalCalories * 0.3 / 9;
    final waterGoal = WaterUtils.calculateWaterGoal(
      weightKg: weight ?? user.weight,
      activityLevel: activityLevel ?? user.activityLevel,
    );

    final updatedUser = user.copyWith(
      weight: weight ?? user.weight,
      height: height ?? user.height,
      age: age ?? user.age,
      isMale: isMale ?? user.isMale,
      activityLevel: activityLevel ?? user.activityLevel,
      goal: goal ?? user.goal,
      calorieGoal: goalCalories,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatGoal: fatGoal,
      waterGoal: waterGoal,
    );

    await _repository.saveUser(updatedUser);
  }
}

class CheckAuthUseCase {
  final AuthService _authService;

  CheckAuthUseCase(this._authService);

  bool call() {
    return _authService.isSignedIn();
  }
}

class SignOutUseCase {
  final AuthService _authService;
  final UserRepository _userRepository;

  SignOutUseCase(this._authService, this._userRepository);

  Future<void> call() async {
    await _authService.signOut();
    _userRepository.clearUser();
  }
}