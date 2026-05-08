import '../../data/models/user_profile_model.dart';

abstract class IUserProfileRepository {
  Future<UserProfileModel?> getCurrentProfile();
  Future<UserProfileModel?> getProfileById(String userId);
  Future<UserProfileModel?> updateProfile(UserProfileModel profile);
  Future<void> updateLastActive();
  Future<void> updateCurrentWeight(double weightKg);
  Future<void> updateGoals({
    double? dailyCalories,
    double? protein,
    double? carbs,
    double? fat,
    double? water,
  });
  Future<void> updateGoalType(String goalType, {double? targetWeight});
  Future<void> calculateAndUpdateMetabolicRates();
  Stream<UserProfileModel?> watchProfile();
}
