import '../entities/food_item.dart';
import '../../data/datasources/ai_food_service.dart';
import '../../data/datasources/usda_food_service.dart';
import '../../data/datasources/local_data_source.dart';
import 'dart:io';

class AnalyzeFoodImageUseCase {
  final AiFoodService _aiService;

  AnalyzeFoodImageUseCase(this._aiService);

  Future<List<FoodItem>> call(File imageFile) async {
    return await _aiService.analyzeFoodImage(imageFile);
  }
}

class SearchFoodUseCase {
  final UsdaFoodService _usdaService;

  SearchFoodUseCase(this._usdaService);

  Future<List<FoodItem>> call(String query) async {
    return await _usdaService.searchFoodByName(query);
  }
}

class GetFoodByBarcodeUseCase {
  final LocalDataSource _localDataSource;

  GetFoodByBarcodeUseCase(this._localDataSource);

  Future<FoodItem?> call(String barcode) async {
    return await _localDataSource.getFoodByBarcode(barcode);
  }
}

class GetRecentFoodsUseCase {
  final LocalDataSource _localDataSource;

  GetRecentFoodsUseCase(this._localDataSource);

  Future<List<FoodItem>> call({int limit = 10}) async {
    return await _localDataSource.getRecentFoods(limit: limit);
  }
}