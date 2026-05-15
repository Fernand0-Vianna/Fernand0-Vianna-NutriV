import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/food_item.dart';
import '../../core/services/logging_service.dart';

class FatSecretService {
  final Dio _dio;
  final String _apiKey;
  final String _consumerKey = '5d8ed3b5f7c44d6d9f5c8e4a6b2d7e3f';

  static const String _baseUrl = 'https://platform.fatsecret.com/rest/api/v1';

  FatSecretService(this._dio) : _apiKey = dotenv.env['FATSECRET_API_KEY'] ?? '';

  Future<List<FoodItem>> searchFoods(String query) async {
    if (_apiKey.isEmpty) {
      LoggingService.warn('FatSecret', 'API key não configurada');
      return [];
    }

    try {
      final params = _buildParams('foods.search', {
        'search_expression': query,
        'max_results': '20',
        'format': 'json',
      });

      final response = await _dio.get(
        '$_baseUrl/foods.search',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return _parseSearchResults(data);
      }
    } catch (e) {
      LoggingService.error('FatSecret', 'searchFoods', e);
    }
    return [];
  }

  Future<FoodItem?> getFoodById(String foodId) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    try {
      final params = _buildParams('food.get', {
        'food_id': foodId,
        'format': 'json',
      });

      final response = await _dio.get(
        '$_baseUrl/food.get',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return _parseFoodDetails(response.data);
      }
    } catch (e) {
      LoggingService.error('FatSecret', 'getFoodById', e);
    }
    return null;
  }

  Map<String, String> _buildParams(String method, Map<String, String> extra) {
    final timestamp = DateTime.now().toUtc().toString().replaceAll('-', '').replaceAll(':', '').split('.').first;
    final nonce = DateTime.now().millisecondsSinceEpoch.toString();

    final allParams = {
      'oauth_consumer_key': _consumerKey,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp,
      'oauth_nonce': nonce,
      'oauth_version': '1.0',
      ...extra,
    };

    final signature = _generateSignature(method, allParams);
    allParams['oauth_signature'] = signature;

    return allParams;
  }

  String _generateSignature(String method, Map<String, String> params) {
    final sortedKeys = params.keys.toList()..sort();
    final paramString = sortedKeys
        .map((key) => '${Uri.encodeComponent(key)}=${Uri.encodeComponent(params[key]!)}')
        .join('&');

    final signatureBase = '$method&${Uri.encodeComponent(_baseUrl)}&${Uri.encodeComponent(paramString)}';

    final key = '${_apiKey}&';
    final hmac = Hmac(sha1, key.codeUnits);
    final digest = hmac.convert(signatureBase.codeUnits);

    return base64Encode(digest.bytes);
  }

  List<FoodItem> _parseSearchResults(dynamic data) {
    try {
      if (data is String) {
        final json = jsonDecode(data);
        data = json;
      }

      final foods = data['foods']?['food'];
      if (foods == null) return [];

      final List<dynamic> foodList = foods is List ? foods : [foods];

      return foodList.map((f) {
        return FoodItem(
          id: f['food_id']?.toString() ?? '',
          name: f['food_name'] ?? '',
          calories: (double.tryParse(f['calories']?.toString() ?? '0') ?? 0) / 100,
          protein: (double.tryParse(f['protein']?.toString() ?? '0') ?? 0) / 100,
          carbs: (double.tryParse(f['carbohydrate']?.toString() ?? '0') ?? 0) / 100,
          fat: (double.tryParse(f['fat']?.toString() ?? '0') ?? 0) / 100,
          portion: 100,
          portionUnit: 'g',
        );
      }).toList();
    } catch (e) {
      LoggingService.error('FatSecret', 'parseSearchResults', e);
      return [];
    }
  }

  FoodItem? _parseFoodDetails(dynamic data) {
    try {
      if (data is String) {
        final json = jsonDecode(data);
        data = json;
      }

      final food = data['food'];
      if (food == null) return null;

      final servings = food['servings']?['serving'];
      final serving = servings is List ? servings.first : servings;

      return FoodItem(
        id: food['food_id']?.toString() ?? '',
        name: food['food_name'] ?? '',
        calories: double.tryParse(serving?['calories']?.toString() ?? '0') ?? 0,
        protein: double.tryParse(serving?['protein']?.toString() ?? '0') ?? 0,
        carbs: double.tryParse(serving?['carbohydrate']?.toString() ?? '0') ?? 0,
        fat: double.tryParse(serving?['fat']?.toString() ?? '0') ?? 0,
        portion: double.tryParse(serving?['serving_amount']?.toString() ?? '100') ?? 100,
        portionUnit: serving?['serving_unit'] ?? 'g',
      );
    } catch (e) {
      LoggingService.error('FatSecret', 'parseFoodDetails', e);
      return null;
    }
  }
}