import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/food_item.dart';
import '../../core/services/logging_service.dart';

class GeminiFoodService {
  final Dio _dio;
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  GeminiFoodService(this._dio);

  Future<List<FoodItem>> analyzeFoodImage(File imageFile) async {
    if (_apiKey.isEmpty) {
      LoggingService.warn('GeminiFood', 'API key não configurada');
      return [];
    }

    try {
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

      final response = await _dio.post(
        '$_baseUrl?key=$_apiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 2048,
          }
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['candidates']?[0]['content']?['parts']?[0]['text'];
        if (content != null) {
          return _parseJsonResponse(content.toString());
        }
      }
    } on DioException catch (e) {
      LoggingService.error('GeminiFood', 'DioError', e.message);
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        LoggingService.warn('GeminiFood', 'API key inválida ou quota esgotada');
      }
    } catch (e) {
      LoggingService.error('GeminiFood', 'Error', e);
    }
    return [];
  }

  Future<List<FoodItem>> analyzeFoodFromText(String text) async {
    if (_apiKey.isEmpty) {
      return [];
    }

    try {
      final prompt = '''Você é um nutricionista expert brasileiro. Com base no texto abaixo, identifique os alimentos e seus valores nutricionais aproximados para 100g.

Texto: "$text"

Retorne UM JSON ARRAY com cada alimento identificado:
[
  {"food_name": "nome do alimento", "portion_size": 100, "calories": valor, "protein": valor, "carbs": valor, "fat": valor}
]

Retorne apenas o JSON array.''';

      final response = await _dio.post(
        '$_baseUrl?key=$_apiKey',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ],
          'generationConfig': {
            'temperature': 0.3,
            'maxOutputTokens': 1024,
          }
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['candidates']?[0]['content']?['parts']?[0]['text'];
        if (content != null) {
          return _parseJsonResponse(content.toString());
        }
      }
    } catch (e) {
      LoggingService.error('GeminiFood', 'analyzeFoodFromText', e);
    }
    return [];
  }

  List<FoodItem> _parseJsonResponse(String text) {
    try {
      String jsonStr = text.trim();
      
      final startBracket = jsonStr.indexOf('[');
      final endBracket = jsonStr.lastIndexOf(']');
      
      if (startBracket != -1 && endBracket != -1 && endBracket > startBracket) {
        jsonStr = jsonStr.substring(startBracket, endBracket + 1);
      } else {
        final startBrace = jsonStr.indexOf('{');
        final endBrace = jsonStr.lastIndexOf('}');
        if (startBrace != -1 && endBrace != -1) {
          jsonStr = '[${jsonStr.substring(startBrace, endBrace + 1)}]';
        }
      }

      final List<dynamic> jsonList = jsonDecode(jsonStr);
      
      return jsonList.map((json) {
        return FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + jsonList.indexOf(json).toString(),
          name: json['food_name'] ?? json['name'] ?? 'Alimento',
          calories: (json['calories'] ?? json['kcal'] ?? 0).toDouble(),
          protein: (json['protein'] ?? 0).toDouble(),
          carbs: (json['carbs'] ?? json['carbohydrates'] ?? 0).toDouble(),
          fat: (json['fat'] ?? 0).toDouble(),
          portion: (json['portion_size'] ?? json['portion'] ?? 100).toDouble(),
          portionUnit: 'g',
        );
      }).toList();
    } catch (e) {
      LoggingService.error('GeminiFood', 'parseJson', e);
      return [];
    }
  }
}