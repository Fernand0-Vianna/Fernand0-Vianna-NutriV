import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import '../models/food_item_model.dart';

class OcrNutritionService {
  static final _log = Logger('OcrNutritionService');
  final Dio _dio;
  String get _geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  OcrNutritionService(this._dio);

  Future<FoodItemModel?> extractNutritionFromImage(File imageFile) async {
    if (_geminiApiKey.isEmpty) {
      throw Exception('API key do Gemini não configurada');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        queryParameters: {'key': _geminiApiKey},
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Analise esta imagem de tabela nutricional de um alimento.
Extraia os seguintes valores porção de 100g:
- calories (kcal)
- protein (g)
- carbs/carbohydrates (g)
- fat (g)
- fiber (g)
- sugar (g)
- sodium (mg)
Retorne apenas JSON com: {"food_name": "nome do alimento", "calories": valor, "protein": valor, "carbs": valor, "fat": valor, "fiber": valor, "sugar": valor, "sodium": valor}. Se não conseguir ler, retorne erro.''',
                },
                {
                  'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image}
                },
              ],
            },
          ],
          'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 1024},
        },
      );

      if (response.statusCode == 200) {
        final text =
            response.data['candidates'][0]['content']['parts'][0]['text'];
        final jsonStr = _extractJsonFromText(text);
        if (jsonStr.isNotEmpty) {
          final Map<String, dynamic> json = jsonDecode(jsonStr);
          return FoodItemModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: json['food_name'] ?? 'Alimento scaneado',
            calories: (json['calories'] as num?)?.toDouble() ?? 0,
            protein: (json['protein'] as num?)?.toDouble() ?? 0,
            carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
            fat: (json['fat'] as num?)?.toDouble() ?? 0,
            fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
            sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
            sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
            portion: 100,
          );
        }
      }
      return null;
    } catch (e) {
      _log.severe('OCR Error: $e');
      return null;
    }
  }

  String _extractJsonFromText(String text) {
    final startBracket = text.indexOf('[');
    final endBracket = text.lastIndexOf(']');
    if (startBracket != -1 && endBracket != -1) {
      return text.substring(startBracket, endBracket + 1);
    }
    final startBrace = text.indexOf('{');
    final endBrace = text.lastIndexOf('}');
    if (startBrace != -1 && endBrace != -1) {
      return text.substring(startBrace, endBrace + 1);
    }
    return '';
  }
}
