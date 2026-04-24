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

      // Usar Gemini 2.0 Flash (mais rápido e gratuito)
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        queryParameters: {'key': ApiConstants.geminiApiKey},
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Você é umnutricionista expert. Analise esta foto de comida e identifique os alimentos presentes.

Retorne uma lista JSON com cada alimento identificado:
[{"food_name": "nome em português", "portion_size": gramas estimadas (número), "calories": kcal por 100g (número), "protein": proteína em g (número), "carbs": carboidratos em g (número), "fat": gordura em g (número)}

Exemplo: [{"food_name": "arroz branco", "portion_size": 150, "calories": 130, "protein": 2.7, "carbs": 28, "fat": 0.3}]

Retorne APENAS o JSON array. Se não conseguir identificar, retorne [].''',
                },
                {
                  'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image},
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 2048,
            'responseMimeType': 'text/plain',
          },
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
      throw Exception('Resposta inválida da API');
    } catch (e) {
      debugPrint('Gemini error: $e');
      
      // Fallback: tentar OpenAI se disponível
      if (_openaiApiKey.isNotEmpty) {
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
          debugPrint('OpenAI error: $e2');
        }
      }
      
      // Fallback final: banco de dados local
      return _getLocalFoods();
    }
  }

  Future<List<FoodItem>> analyzeFoodFromText(String text) async {
    if (_openaiApiKey.isNotEmpty) {
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
      } catch (e) {
        debugPrint('OpenAI failed: $e');
      }
    }
    return _searchLocalDatabase(text);
  }

  Future<List<FoodItem>> _searchLocalDatabase(String searchText) async {
    final localFoods = _getLocalFoods();
    final query = searchText.toLowerCase();
    
    return localFoods.where((food) {
      return food.name.toLowerCase().contains(query) ||
          food.name.toLowerCase().split(' ').any((word) => word.startsWith(query.substring(0, query.length > 3 ? 3 : query.length)));
    }).toList();
  }

  List<FoodItem> _getLocalFoods() {
    return [
      FoodItem(id: '1', name: 'Arroz branco cozido', calories: 130, protein: 2.7, carbs: 28, fat: 0.3, portion: 100, portionUnit: 'g'),
      FoodItem(id: '2', name: 'Feijão carioca', calories: 127, protein: 8.7, carbs: 22.8, fat: 0.5, portion: 100, portionUnit: 'g'),
      FoodItem(id: '3', name: 'Frango peito grelhado', calories: 165, protein: 31, carbs: 0, fat: 3.6, portion: 100, portionUnit: 'g'),
      FoodItem(id: '4', name: 'Bife bovino grelhado', calories: 271, protein: 25.4, carbs: 0, fat: 18.8, portion: 100, portionUnit: 'g'),
      FoodItem(id: '5', name: 'Ovo cozido', calories: 155, protein: 12.6, carbs: 1.1, fat: 10.6, portion: 100, portionUnit: 'g'),
      FoodItem(id: '6', name: 'Salada verde', calories: 20, protein: 1.5, carbs: 3.3, fat: 0.2, portion: 100, portionUnit: 'g'),
      FoodItem(id: '7', name: 'Batata cozida', calories: 87, protein: 1.9, carbs: 20, fat: 0.1, portion: 100, portionUnit: 'g'),
      FoodItem(id: '8', name: 'Macarrão cozido', calories: 131, protein: 5, carbs: 25, fat: 1.1, portion: 100, portionUnit: 'g'),
      FoodItem(id: '9', name: 'Pão francês', calories: 265, protein: 8, carbs: 51, fat: 3.2, portion: 50, portionUnit: 'g'),
      FoodItem(id: '10', name: 'Leite integral', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, portion: 100, portionUnit: 'ml'),
      FoodItem(id: '11', name: 'Iogurte natural', calories: 61, protein: 3.5, carbs: 4.7, fat: 3.3, portion: 100, portionUnit: 'g'),
      FoodItem(id: '12', name: 'BANANA', calories: 89, protein: 1.1, carbs: 22.8, fat: 0.3, portion: 100, portionUnit: 'g'),
      FoodItem(id: '13', name: 'Maçã', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, portion: 100, portionUnit: 'g'),
      FoodItem(id: '14', name: 'Laranja', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, portion: 100, portionUnit: 'g'),
      FoodItem(id: '15', name: 'Abacate', calories: 160, protein: 2, carbs: 8.5, fat: 14.7, portion: 100, portionUnit: 'g'),
      FoodItem(id: '16', name: 'Batata frita', calories: 312, protein: 3.4, carbs: 41, fat: 15, portion: 100, portionUnit: 'g'),
      FoodItem(id: '17', name: 'Hambúrguer', calories: 295, protein: 17, carbs: 24, fat: 14, portion: 100, portionUnit: 'g'),
      FoodItem(id: '18', name: 'Pizza', calories: 266, protein: 11, carbs: 33, fat: 10, portion: 100, portionUnit: 'g'),
      FoodItem(id: '19', name: 'Lasanha', calories: 132, protein: 5.5, carbs: 14, fat: 5.8, portion: 100, portionUnit: 'g'),
      FoodItem(id: '20', name: 'Suco de laranja', calories: 45, protein: 0.7, carbs: 10, fat: 0.2, portion: 100, portionUnit: 'ml'),
      FoodItem(id: '21', name: 'Refrigerante', calories: 38, protein: 0, carbs: 10, fat: 0, portion: 100, portionUnit: 'ml'),
      FoodItem(id: '22', name: 'Cerveja', calories: 43, protein: 0.5, carbs: 3.6, fat: 0, portion: 100, portionUnit: 'ml'),
      FoodItem(id: '23', name: 'Vinho tinto', calories: 83, protein: 0.1, carbs: 2.6, fat: 0, portion: 100, portionUnit: 'ml'),
      FoodItem(id: '24', name: 'Café com açúcar', calories: 35, protein: 0.3, carbs: 8.5, fat: 0.1, portion: 100, portionUnit: 'ml'),
      FoodItem(id: '25', name: 'Pudim', calories: 115, protein: 3, carbs: 20, fat: 3.5, portion: 100, portionUnit: 'g'),
      FoodItem(id: '26', name: 'Brócolis', calories: 34, protein: 2.8, carbs: 7, fat: 0.4, portion: 100, portionUnit: 'g'),
      FoodItem(id: '27', name: 'Cenoura', calories: 41, protein: 0.9, carbs: 10, fat: 0.2, portion: 100, portionUnit: 'g'),
      FoodItem(id: '28', name: 'Tomate', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, portion: 100, portionUnit: 'g'),
      FoodItem(id: '29', name: 'Cebola', calories: 40, protein: 1.1, carbs: 9.3, fat: 0.1, portion: 100, portionUnit: 'g'),
      FoodItem(id: '30', name: 'Alho', calories: 149, protein: 6.4, carbs: 33, fat: 0.5, portion: 100, portionUnit: 'g'),
    ];
  }

  Future<List<FoodItem>> searchOpenFoodFacts(String searchText) async {
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
    final startBrace = text.indexOf('{');
    final endBrace = text.lastIndexOf('}');
    if (startBrace >= 0 && endBrace >= 0) {
      return '[${text.substring(startBrace, endBrace + 1)}]';
    }
    return text;
  }
}