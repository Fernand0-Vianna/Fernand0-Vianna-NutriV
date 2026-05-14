import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/food_item_model.dart';
import '../../domain/entities/food_item.dart';
import '../../core/services/logging_service.dart';

class GroqVisionService {
  final Dio _dio;
  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama-3.2-11b-vision-preview';
  static const String _fallbackModel = 'llama-3.2-90b-vision-preview';

  GroqVisionService(this._dio);

  Future<List<FoodItem>> analyzeFoodImage(File imageFile) async {
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY não configurada no arquivo .env');
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final prompt = '''Você é um nutricionista expert brasileiro. Analise esta foto de comida e identifique os alimentos presentes na imagem.

Retorne UM JSON ARRAY contendo cada alimento identificado com:
- food_name: nome do alimento em português (ex: "arroz branco", "frango grelhado", "salada verde")
- portion_size: tamanho da porção em gramas (ex: 150, 200)
- calories: calorias totais da porção (ex: 130, 200)
- protein: proteína em gramas (ex: 2.7, 31)
- carbs: carboidratos em gramas (ex: 28, 0)
- fat: gordura em gramas (ex: 0.3, 3.6)

Exemplo de resposta esperada:
[
  {"food_name": "arroz branco", "portion_size": 150, "calories": 195, "protein": 4.3, "carbs": 44.7, "fat": 0.4},
  {"food_name": "frango grelhado", "portion_size": 120, "calories": 198, "protein": 37.2, "carbs": 0, "fat": 4.8}
]

Retorne apenas o JSON array, sem texto adicional. Se não conseguir identificar alimentos, retorne um array vazio [].''';

    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'temperature': 0.3,
          'max_tokens': 2048,
          'response_format': {'type': 'json_object'},
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        final jsonStr = _extractJsonFromText(content);

        if (jsonStr.isNotEmpty) {
          List<dynamic> jsonList;
          try {
            jsonList = jsonDecode(jsonStr);
          } catch (e) {
            LoggingService.error('GroqVision', 'parse JSON', e);
            return [];
          }

          if (jsonList.isEmpty) {
            return [];
          }

          return jsonList
              .map((json) => FoodItemModel.fromAiResponse(json as Map<String, dynamic>))
              .toList();
        }
      }

      LoggingService.warn('GroqVision', 'resposta inesperada - ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      LoggingService.error('GroqVision', 'DioError', e.message);
      if (e.response?.statusCode == 401) {
        throw Exception('API Key do Groq inválida ou expirada');
      }
      return _fallbackAnalyze(imageFile);
    } catch (e) {
      LoggingService.error('GroqVision', 'Error', e);
      return _fallbackAnalyze(imageFile);
    }
  }

  Future<List<FoodItem>> _fallbackAnalyze(File imageFile) async {
    if (_apiKey.isEmpty) {
      LoggingService.warn('GroqVision', 'Sem API key para fallback');
      return [];
    }

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      final response = await _dio.post(
        '$_baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': _fallbackModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Analise esta foto de comida. Retorne JSON array com: food_name, portion_size, calories, protein, carbs, fat'
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
                }
              ]
            }
          ],
          'temperature': 0.3,
          'max_tokens': 1024,
          'response_format': {'type': 'json_object'},
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        final jsonStr = _extractJsonFromText(content);

        if (jsonStr.isNotEmpty) {
          final jsonList = jsonDecode(jsonStr);
          return jsonList
              .map((json) => FoodItemModel.fromAiResponse(json as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      LoggingService.error('GroqVision', 'fallback error', e);
    }

    return [];
  }

  String _extractJsonFromText(String text) {
    final startBracket = text.indexOf('[');
    final endBracket = text.lastIndexOf(']');

    if (startBracket != -1 && endBracket != -1 && endBracket > startBracket) {
      return text.substring(startBracket, endBracket + 1);
    }

    final startBrace = text.indexOf('{');
    final endBrace = text.lastIndexOf('}');

    if (startBrace != -1 && endBrace != -1 && endBrace > startBrace) {
      return '[${text.substring(startBrace, endBrace + 1)}]';
    }

    return text.trim();
  }
}