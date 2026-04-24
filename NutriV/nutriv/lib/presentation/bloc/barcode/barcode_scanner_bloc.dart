import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../domain/entities/food_item.dart';
import '../../../core/constants/app_constants.dart';
import 'barcode_scanner_event.dart';
import 'barcode_scanner_state.dart';

class BarcodeScannerBloc
    extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
  final Dio _dio = Dio();

  BarcodeScannerBloc() : super(BarcodeScannerInitial()) {
    on<StartBarcodeScan>(_onStartScan);
    on<BarcodeDetected>(_onBarcodeDetected);
    on<ClearBarcode>(_onClearBarcode);
  }

  void _onStartScan(StartBarcodeScan event, Emitter<BarcodeScannerState> emit) {
    emit(BarcodeScannerScanning());
  }

  Future<void> _onBarcodeDetected(
    BarcodeDetected event,
    Emitter<BarcodeScannerState> emit,
  ) async {
    emit(BarcodeScannerScanning());

    try {
      var food = await _fetchFromOpenFoodFacts(event.barcode);
      
      // Se macros estiverem zerados, usar Gemini para enriquecer
      if (food != null && (food.calories == 0 || food.protein == 0)) {
        final enrichedFood = await _enrichWithGemini(food.name);
        if (enrichedFood != null && enrichedFood.protein > 0) {
          food = enrichedFood;
        }
      }
      
      if (food != null && food.calories > 0) {
        emit(BarcodeScannerSuccess(barcode: event.barcode, food: food));
      } else {
        final localFood = _searchLocalDatabase(event.barcode);
        if (localFood != null) {
          emit(BarcodeScannerSuccess(barcode: event.barcode, food: localFood));
        } else {
          emit(BarcodeNotFound(event.barcode));
        }
      }
    } catch (e) {
      debugPrint('Barcode error: $e');
      final localFood = _searchLocalDatabase(event.barcode);
      if (localFood != null) {
        emit(BarcodeScannerSuccess(barcode: event.barcode, food: localFood));
      } else {
        emit(BarcodeNotFound(event.barcode));
      }
    }
  }

  Future<FoodItem?> _enrichWithGemini(String foodName) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
        queryParameters: {'key': ApiConstants.geminiApiKey},
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '''Qual é a informação nutricional de "$foodName" por 100g?
Retorne apenas JSON: {"name": "nome", "calories": número, "protein": número, "carbs": número, "fat": número}''',                },
              ],
            },
          ],
          'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 256},
        },
      );

      if (response.statusCode == 200) {
        final text = response.data['candidates'][0]['content']['parts'][0]['text'];
        final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(text);
        if (jsonMatch != null) {
          final data = _parseSimpleJson(jsonMatch.group(0)!);
          return FoodItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: data['name'] ?? foodName,
            calories: (data['calories'] ?? 0).toDouble(),
            protein: (data['protein'] ?? 0).toDouble(),
            carbs: (data['carbs'] ?? 0).toDouble(),
            fat: (data['fat'] ?? 0).toDouble(),
            portion: 100,
            portionUnit: 'g',
          );
        }
      }
    } catch (e) {
      debugPrint('Gemini enrich error: $e');
    }
    return null;
  }

  Map<String, dynamic> _parseSimpleJson(String json) {
    final result = <String, dynamic>{};
    final patterns = {
      'name': RegExp(r'"name"\s*:\s*"([^"]+)"'),
      'calories': RegExp(r'"calories"\s*:\s*(\d+(?:\.\d+)?)'),
      'protein': RegExp(r'"protein"\s*:\s*(\d+(?:\.\d+)?)'),
      'carbs': RegExp(r'"carbs"\s*:\s*(\d+(?:\.\d+)?)'),
      'fat': RegExp(r'"fat"\s*:\s*(\d+(?:\.\d+)?)'),
    };
    for (var entry in patterns.entries) {
      final match = entry.value.firstMatch(json);
      if (match != null) {
        final value = match.group(1)!;
        if (entry.key == 'name') {
          result[entry.key] = value;
        } else {
          result[entry.key] = double.tryParse(value) ?? 0;
        }
      }
    }
    return result;
  }

  Future<FoodItem?> _fetchFromOpenFoodFacts(String barcode) async {
    try {
      final response = await _dio.get(
        'https://world.openfoodfacts.org/product/$barcode.json',
        queryParameters: {
          'fields':
              'product_name,nutriments,brands,quantity,serving_size,packing',
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final product = response.data['product'];
        if (product == null) return null;

        final nutriments = product['nutriments'] ?? {};
        final name =
            product['product_name'] ??
            product['brands'] ??
            'Produto desconhecido';

        if (name == 'Produto desconhecido' && product['brands'] == null) {
          return null;
        }

        final portionMatch = RegExp(
          r'(\d+(?:\.\d+)?)\s*(g|ml|mg)',
        ).firstMatch(product['quantity']?.toString() ?? '');
        final defaultPortion = portionMatch != null
            ? double.tryParse(portionMatch.group(1) ?? '100') ?? 100.0
            : 100.0;
        final portionUnit = portionMatch?.group(2) ?? 'g';

        return FoodItem(
          id: barcode,
          name: name.toString(),
          calories: (nutriments['energy-kcal_100g'] ?? 0.0).toDouble(),
          protein:
              (nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0.0)
                  .toDouble(),
          carbs:
              (nutriments['carbohydrates_100g'] ??
                      nutriments['carbohydrates'] ??
                      0.0)
                  .toDouble(),
          fat: (nutriments['fat_100g'] ?? nutriments['fat'] ?? 0.0).toDouble(),
          portion: defaultPortion,
          portionUnit: portionUnit,
          barcode: barcode,
        );
      }
    } catch (_) {}
    return null;
  }

  void _onClearBarcode(ClearBarcode event, Emitter<BarcodeScannerState> emit) {
    emit(BarcodeScannerInitial());
  }

  FoodItem? _searchLocalDatabase(String barcode) {
    final database = _getLocalFoodDatabase();
    try {
      return database.firstWhere((f) => f.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  List<FoodItem> _getLocalFoodDatabase() {
    return const [
      FoodItem(
        id: '1',
        name: 'Leite Integral',
        calories: 61,
        protein: 3.2,
        carbs: 4.8,
        fat: 3.3,
        portion: 100,
        portionUnit: 'ml',
        barcode: '7891000029100',
      ),
      FoodItem(
        id: '2',
        name: 'Pão Francês',
        calories: 70,
        protein: 2.5,
        carbs: 14,
        fat: 0.8,
        portion: 50,
        portionUnit: 'g',
        barcode: '7896006712345',
      ),
      FoodItem(
        id: '3',
        name: 'Ovo de Galinha',
        calories: 155,
        protein: 13,
        carbs: 1.1,
        fat: 11,
        portion: 100,
        portionUnit: 'g',
        barcode: '7891234567890',
      ),
      FoodItem(
        id: '4',
        name: 'Arroz Branco Cozido',
        calories: 130,
        protein: 2.7,
        carbs: 28,
        fat: 0.3,
        portion: 100,
        portionUnit: 'g',
      ),
      FoodItem(
        id: '5',
        name: 'Feijão Preto Cozido',
        calories: 127,
        protein: 8.9,
        carbs: 22.8,
        fat: 0.5,
        portion: 100,
        portionUnit: 'g',
      ),
      FoodItem(
        id: '6',
        name: 'Banana Prata',
        calories: 89,
        protein: 1.1,
        carbs: 22.8,
        fat: 0.3,
        portion: 100,
        portionUnit: 'g',
      ),
      FoodItem(
        id: '7',
        name: 'Maçã',
        calories: 52,
        protein: 0.3,
        carbs: 14,
        fat: 0.2,
        portion: 100,
        portionUnit: 'g',
      ),
      FoodItem(
        id: '8',
        name: 'Peito de Frango',
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        portion: 100,
        portionUnit: 'g',
      ),
      FoodItem(
        id: '9',
        name: 'Iogurte Natural',
        calories: 59,
        protein: 10,
        carbs: 3.6,
        fat: 0.4,
        portion: 100,
        portionUnit: 'g',
      ),
      FoodItem(
        id: '10',
        name: 'Azeite de Oliva',
        calories: 884,
        protein: 0,
        carbs: 0,
        fat: 100,
        portion: 100,
        portionUnit: 'ml',
      ),
    ];
  }
}
