import '../../data/models/favorite_dish_model.dart';

abstract class IFavoriteDishRepository {
  Future<List<FavoriteDishModel>> getFavoriteDishes();
  Future<FavoriteDishModel?> getFavoriteDishById(String id);
  Future<FavoriteDishModel> addFavoriteDish(FavoriteDishModel dish);
  Future<void> updateFavoriteDish(String id, FavoriteDishModel dish);
  Future<void> deleteFavoriteDish(String id);
  Future<void> updateTimesUsed(String id, int timesUsed);
  Future<void> saveDishFromMeal({
    required String name,
    required List<FavoriteDishItem> items,
  });
  Stream<List<FavoriteDishModel>> watchFavoriteDishes();
}
