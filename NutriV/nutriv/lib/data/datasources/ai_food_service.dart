import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' show Dio, Options;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/constants/app_constants.dart';
import '../models/food_item_model.dart';
import '../../domain/entities/food_item.dart';

String get _openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

class AiFoodService {
  final Dio _dio;

  AiFoodService(this._dio);

  Future<List<FoodItem>> analyzeFoodImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        queryParameters: {'key': ApiConstants.geminiApiKey},
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Analise esta imagem de comida e retorne um JSON array com os alimentos identificados. Para cada alimento, retorne:
                  {
                    "food_name": "nome do alimento em português",
                    "portion_size": tamanho da porção em gramas (número),
                    "calories": valor calórico (número),
                    "protein": proteína em gramas (número),
                    "carbs": carboidratos em gramas (número),
                    "fat": gordura em gramas (número),
                    "fiber": fibra em gramas (número, opcional),
                    "sugar": açúcar em gramas (número, opcional)
                  }
                  Retorne apenas o JSON array, sem texto adicional. Se não conseguir identificar, retorne um array vazio [].''',
                },
                {
                  'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
                },
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 2048},
        },
      );

      if (response.statusCode == 200) {
        final text =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        final jsonStr = _extractJsonFromText(text);

        if (jsonStr.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(jsonStr);
          return jsonList
              .map((json) => FoodItemModel.fromAiResponse(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error analyzing food image: $e, trying OpenAI');
      try {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        final response = await _dio.post(
          'https://api.openai.com/v1/chat/completions',
          options: Options(headers: {'Authorization': 'Bearer $_openaiApiKey'}),
          data: {
            'model': 'gpt-4o-mini',
            'messages': [
              {
                'role': 'user',
                'content': [
                  {
                    'type': 'text',
                    'text':
                        'Analise esta imagem de comida. Retorne JSON array: food_name, portion_size, calories, protein, carbs, fat',
                  },
                  {
                    'type': 'image_url',
                    'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                  },
                ],
              },
            ],
            'max_tokens': 2048,
          },
        );
        if (response.statusCode == 200) {
          final text = response.data['choices'][0]['message']['content'];
          final jsonStr = _extractJsonFromText(text);
          if (jsonStr.isNotEmpty) {
            final List<dynamic> jsonList = jsonDecode(jsonStr);
            return jsonList
                .map((json) => FoodItemModel.fromAiResponse(json))
                .toList();
          }
        }
      } catch (e2) {
        debugPrint('OpenAI image failed: $e2');
      }
      return [];
    }
  }

  Future<List<FoodItem>> analyzeFoodFromText(String text) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        queryParameters: {'key': ApiConstants.geminiApiKey},
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Com base na descrição "$text", identifique os alimentos e retorne um JSON array com:
                  {
                    "food_name": "nome do alimento em português",
                    "portion_size": tamanho da porção em gramas (número),
                    "calories": valor calórico (número),
                    "protein": proteína em gramas (número),
                    "carbs": carboidratos em gramas (número),
                    "fat": gordura em gramas (número)
                  }
                  Retorne apenas o JSON array, sem texto adicional.''',
                },
              ],
            },
          ],
          'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1024},
        },
      );

      if (response.statusCode == 200) {
        final text =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        final jsonStr = _extractJsonFromText(text);

        if (jsonStr.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(jsonStr);
          return jsonList
              .map((json) => FoodItemModel.fromAiResponse(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error analyzing food from text: $e, trying OpenAI');
      try {
        final response = await _dio.post(
          'https://api.openai.com/v1/chat/completions',
          options: Options(headers: {'Authorization': 'Bearer $_openaiApiKey'}),
          data: {
            'model': 'gpt-4o-mini',
            'messages': [
              {
                'role': 'user',
                'content':
                    '''Com base na descrição "$text", identifique os alimentos e retorne um JSON array com: food_name, portion_size (em gramas), calories, protein, carbs, fat. Exemplo: [{"food_name": "arroz", "portion_size": 100, "calories": 130, "protein": 2.7, "carbs": 28, "fat": 0.3}] Retorne apenas o JSON array.''',
              },
            ],
            'max_tokens': 1024,
          },
        );
        if (response.statusCode == 200) {
          final text = response.data['choices'][0]['message']['content'];
          final jsonStr = _extractJsonFromText(text);
          if (jsonStr.isNotEmpty) {
            final List<dynamic> jsonList = jsonDecode(jsonStr);
            return jsonList
                .map((json) => FoodItemModel.fromAiResponse(json))
                .toList();
          }
        }
      } catch (e2) {
        debugPrint('OpenAI failed: $e2, trying OpenFoodFacts');
      }
      return _searchOpenFoodFacts(text);
    }
  }

  Future<List<FoodItem>> _searchOpenFoodFacts(String searchText) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodfacts.org/cgi/search.pl',
        queryParameters: {
          'search_terms': searchText,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page_size': 10,
          'fields': 'product_name,nutriments,brands,quantity',
        },
      );

      if (response.statusCode == 200 && response.data['products'] != null) {
        final products = response.data['products'] as List;
        if (products.isEmpty) return [];

        return products
            .where((p) => p['product_name'] != null)
            .map((p) => _parseProduct(p))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  FoodItem _parseProduct(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] ?? {};

    return FoodItem(
      id: product['code'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: product['product_name'] ?? product['brands'] ?? 'Produto',
      calories: (nutriments['energy-kcal_100g'] ?? 0.0).toDouble(),
      protein: (nutriments['proteins_100g'] ?? 0.0).toDouble(),
      carbs: (nutriments['carbohydrates_100g'] ?? 0.0).toDouble(),
      fat: (nutriments['fat_100g'] ?? 0.0).toDouble(),
      portion: 100.0,
      portionUnit: 'g',
    );
  }

  String _extractJsonFromText(String text) {
    final startBracket = text.indexOf('[');
    final endBracket = text.lastIndexOf(']');

    if (startBracket >= 0 && endBracket >= 0) {
      return text.substring(startBracket, endBracket + 1);
    }
    return text;
  }
}
