import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/food_item.dart';

class UsdaFoodService {
  final Dio _dio;
  final String _apiKey;

  UsdaFoodService(this._dio) : _apiKey = dotenv.env['USDA_API_KEY'] ?? '';

  Future<List<FoodItem>> searchFoodByName(String query) async {
    if (_apiKey.isEmpty) {
      debugPrint('USDA API key not configured');
      return [];
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

        return foods.map((f) => _parseUsdaFood(f)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('USDA search error: $e');
      return [];
    }
  }

  Future<FoodItem?> getFoodByFdcId(String fdcId) async {
    if (_apiKey.isEmpty) return null;

    try {
      final response = await _dio.get(
        'https://api.nal.usda.gov/fdc/v1/food/$fdcId',
        queryParameters: {'api_key': _apiKey},
      );

      if (response.statusCode == 200) {
        return _parseUsdaFoodDetail(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('USDA get food error: $e');
      return null;
    }
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
      id:
          food['fdcId']?.toString() ??
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
