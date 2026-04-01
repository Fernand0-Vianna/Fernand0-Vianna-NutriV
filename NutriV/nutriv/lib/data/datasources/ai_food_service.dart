import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../models/food_item_model.dart';
import '../../domain/entities/food_item.dart';

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
      debugPrint('Error analyzing food image: $e');
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
      debugPrint('Error analyzing food from text: $e');
      return [];
    }
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
