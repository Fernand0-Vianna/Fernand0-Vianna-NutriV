import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/food_item.dart';
import '../database/database_helper.dart';
import '../../core/services/logging_service.dart';

class UsdaFoodService {
  final Dio _dio;
  final DatabaseHelper _db;
  final String _apiKey;

  UsdaFoodService(this._dio, this._db)
    : _apiKey = dotenv.env['USDA_API_KEY'] ?? '';

  Future<List<FoodItem>> searchFoodByName(String query) async {
    if (_apiKey.isEmpty) {
      LoggingService.warn('USDA', 'API key not configured');
      return [];
    }

    final searchKey = query.toLowerCase().trim();

    try {
      final cached = await _db.getCachedFoods(searchKey);
      if (cached.isNotEmpty) {
        LoggingService.info('USDA', 'cache hit for "$searchKey" (${cached.length} items)');
        return cached.map(_parseCachedFood).toList();
      }
    } catch (e) {
      LoggingService.error('USDA', 'cache read error', e);
    }

    try {
      final response = await _dio.get(
        'https://api.nal.usda.gov/fdc/v1/foods/search',
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'pageSize': 10,
          'dataType': ['Foundation', 'SR Legacy'],
        },
      );

      if (response.statusCode == 200) {
        final foods = response.data['foods'] as List?;
        if (foods == null || foods.isEmpty) return [];

        final foodItems = foods.map((f) => _parseUsdaFood(f)).toList();
        await _cacheFoods(foodItems, searchKey);
        return foodItems;
      }
      return [];
    } catch (e) {
      LoggingService.error('USDA', 'search error', e);
      return [];
    }
  }

  Future<FoodItem?> getFoodByFdcId(String fdcId) async {
    if (_apiKey.isEmpty) return null;

    try {
      final cached = await _db.getCachedFoodById(fdcId);
      if (cached != null) {
        LoggingService.info('USDA', 'cache hit for food ID $fdcId');
        return _parseCachedFood(cached);
      }
    } catch (e) {
      LoggingService.error('USDA', 'cache read error', e);
    }

    try {
      final response = await _dio.get(
        'https://api.nal.usda.gov/fdc/v1/food/$fdcId',
        queryParameters: {'api_key': _apiKey},
      );

      if (response.statusCode == 200) {
        final food = _parseUsdaFoodDetail(response.data);
        await _cacheSingleFood(food, fdcId.toLowerCase());
        return food;
      }
      return null;
    } catch (e) {
      LoggingService.error('USDA', 'get food error', e);
      return null;
    }
  }

  Future<void> _cacheFoods(List<FoodItem> foods, String searchKey) async {
    try {
      final cachedEntries = foods.map((food) {
        return {
          'id': food.id,
          'name': food.name,
          'calories': food.calories,
          'protein': food.protein,
          'carbs': food.carbs,
          'fat': food.fat,
          'fiber': food.fiber,
          'sugar': food.sugar,
          'sodium': food.sodium,
          'portion': food.portion,
          'portion_unit': food.portionUnit,
          'image_url': food.imageUrl,
          'barcode': food.barcode,
          'source': 'usda',
          'search_key': searchKey,
          'cached_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _db.cacheFoods(cachedEntries);
      LoggingService.info('USDA', 'Cached ${foods.length} foods for "$searchKey"');
    } catch (e) {
      LoggingService.error('USDA', 'cache write error', e);
    }
  }

  Future<void> _cacheSingleFood(FoodItem food, String searchKey) async {
    try {
      await _db.cacheFood({
        'id': food.id,
        'name': food.name,
        'calories': food.calories,
        'protein': food.protein,
        'carbs': food.carbs,
        'fat': food.fat,
        'fiber': food.fiber,
        'sugar': food.sugar,
        'sodium': food.sodium,
        'portion': food.portion,
        'portion_unit': food.portionUnit,
        'image_url': food.imageUrl,
        'barcode': food.barcode,
        'source': 'usda',
        'search_key': searchKey,
        'cached_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      LoggingService.error('USDA', 'cache write error', e);
    }
  }

  FoodItem _parseCachedFood(Map<String, dynamic> food) {
    return FoodItem(
      id: food['id'] as String,
      name: food['name'] as String,
      calories: (food['calories'] as num).toDouble(),
      protein: (food['protein'] as num).toDouble(),
      carbs: (food['carbs'] as num).toDouble(),
      fat: (food['fat'] as num).toDouble(),
      fiber: (food['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (food['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (food['sodium'] as num?)?.toDouble() ?? 0,
      portion: (food['portion'] as num).toDouble(),
      portionUnit: food['portion_unit'] as String? ?? 'g',
      imageUrl: food['image_url'] as String?,
      barcode: food['barcode'] as String?,
    );
  }

  FoodItem _parseUsdaFood(Map<String, dynamic> food) {
    final nutrients = food['foodNutrients'] as List? ?? [];

    double getNutrient(int nutrientId) {
      for (final n in nutrients) {
        if (n['nutrientId'] == nutrientId ||
            n['nutrient']?['id'] == nutrientId) {
          return (n['value'] ?? n['number'] ?? 0.0).toDouble();
        }
      }
      return 0.0;
    }

    return FoodItem(
      id: food['fdcId']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: food['description'] ?? food['lowercaseDescription'] ?? 'Alimento',
      calories: (getNutrient(1008) as num).toDouble(),
      protein: (getNutrient(1003) as num).toDouble(),
      carbs: (getNutrient(1005) as num).toDouble(),
      fat: (getNutrient(1004) as num).toDouble(),
      portion: 100.0,
      portionUnit: 'g',
      fiber: (getNutrient(1079) as num).toDouble(),
      sugar: (getNutrient(2000) as num).toDouble(),
    );
  }

  FoodItem _parseUsdaFoodDetail(Map<String, dynamic> food) {
    final nutrients = food['foodNutrients'] as List? ?? [];

    double getNutrient(int nutrientId) {
      for (final n in nutrients) {
        if (n['nutrientId'] == nutrientId) {
          return (n['value'] ?? 0.0).toDouble();
        }
      }
      return 0.0;
    }

    return FoodItem(
      id: food['fdcId']?.toString() ?? '',
      name: food['description'] ?? 'Alimento',
      calories: getNutrient(1008),
      protein: getNutrient(1003),
      carbs: getNutrient(1005),
      fat: getNutrient(1004),
      portion: 100.0,
      portionUnit: 'g',
      fiber: getNutrient(1079),
      sugar: getNutrient(2000),
    );
  }
}
