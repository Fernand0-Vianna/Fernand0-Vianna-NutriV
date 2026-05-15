import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/ai_food_service.dart';
import '../../../data/datasources/groq_vision_service.dart';
import '../../../data/datasources/usda_food_service.dart';
import '../../../data/datasources/fatsecret_service.dart';
import '../../../data/datasources/gemini_food_service.dart';
import '../../../domain/entities/food_item.dart';
import '../../../core/services/logging_service.dart';
import 'food_scanner_event.dart';
import 'food_scanner_state.dart';

class FoodScannerBloc extends Bloc<FoodScannerEvent, FoodScannerState> {
  final AiFoodService _aiFoodService;
  final GroqVisionService _groqVisionService;
  final UsdaFoodService _usdaFoodService;
  final FatSecretService _fatSecretService;
  final GeminiFoodService _geminiFoodService;

  FoodScannerBloc(
    this._aiFoodService,
    this._groqVisionService,
    this._usdaFoodService,
    this._fatSecretService,
    this._geminiFoodService,
  ) : super(FoodScannerInitial()) {
    on<AnalyzeImage>(_onAnalyzeImage);
    on<AnalyzeText>(_onAnalyzeText);
    on<SearchFoodByName>(_onSearchFoodByName);
    on<ClearScannedFoods>(_onClearScannedFoods);
    on<SelectFood>(_onSelectFood);
    on<DeselectFood>(_onDeselectFood);
    on<UpdateFoodPortion>(_onUpdateFoodPortion);
    on<RemoveSelectedFood>(_onRemoveSelectedFood);
  }

  Future<void> _onAnalyzeImage(
    AnalyzeImage event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(FoodScannerLoading());
    try {
      List<FoodItem> foods = [];

      // Fluxo: Gemini → Groq Vision → AiFoodService (fallback linear)
      try {
        foods = await _geminiFoodService.analyzeFoodImage(event.imageFile);
        LoggingService.info('FoodScannerBloc', 'Gemini retornou ${foods.length} alimentos');
        if (foods.isNotEmpty) {
          foods = await _validateWithUSDA(foods);
        }
      } catch (e) {
        LoggingService.warn('FoodScannerBloc', 'Gemini falhou: $e');
      }

      if (foods.isEmpty) {
        try {
          foods = await _groqVisionService.analyzeFoodImage(event.imageFile);
          LoggingService.info('FoodScannerBloc', 'Groq Vision retornou ${foods.length} alimentos');
        } catch (e) {
          LoggingService.warn('FoodScannerBloc', 'Groq falhou: $e');
        }
      }

      if (foods.isEmpty) {
        try {
          foods = await _aiFoodService.analyzeFoodImage(event.imageFile);
          LoggingService.info('FoodScannerBloc', 'AiFoodService retornou ${foods.length} alimentos');
        } catch (e) {
          LoggingService.error('FoodScannerBloc', 'Todos os serviços falharam', e);
        }
      }

      if (foods.isEmpty) {
        emit(
          const FoodScannerError(
            'Não foi possível identificar os alimentos. Tente novamente com uma imagem mais clara.',
          ),
        );
      } else {
        emit(FoodScannerAnalyzed(scannedFoods: foods, selectedFoods: const []));
      }
    } catch (e) {
      LoggingService.error('FoodScannerBloc', 'AnalyzeImage', e);
      emit(
        const FoodScannerError(
          'Erro ao analisar imagem. Verifique sua conexão e tente novamente.',
        ),
      );
    }
  }

  Future<List<FoodItem>> _validateWithUSDA(List<FoodItem> foods) async {
    try {
      final validatedFoods = <FoodItem>[];
      
      for (final food in foods) {
        // Buscar no USDA para obter dados mais precisos
        final usdaResults = await _usdaFoodService.searchFoodByName(food.name);
        
        if (usdaResults.isNotEmpty) {
          // Usar dados do USDA para refinar os valores
          final usdaFood = usdaResults.first;
          validatedFoods.add(food.copyWith(
            calories: usdaFood.calories,
            protein: usdaFood.protein,
            carbs: usdaFood.carbs,
            fat: usdaFood.fat,
            fiber: usdaFood.fiber,
          ));
          LoggingService.info('FoodScannerBloc', 'USDA validou: ${food.name}');
        } else {
          // Manter dados do Gemini se USDA não encontrar
          validatedFoods.add(food);
        }
      }
      
      return validatedFoods;
    } catch (e) {
      LoggingService.warn('FoodScannerBloc', 'Validação USDA falhou: $e');
      return foods;
    }
  }

  Future<void> _onAnalyzeText(
    AnalyzeText event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(FoodScannerLoading());
    try {
      List<FoodItem> foods = [];

      try {
        foods = await _usdaFoodService.searchFoodByName(event.text);
        LoggingService.info('FoodScannerBloc', 'USDA retornou ${foods.length} alimentos');
      } catch (e) {
        LoggingService.warn('FoodScannerBloc', 'USDA falhou: $e');
      }

      if (foods.isEmpty) {
        try {
          foods = await _geminiFoodService.analyzeFoodFromText(event.text);
          LoggingService.info('FoodScannerBloc', 'Gemini retornou ${foods.length} alimentos');
          if (foods.isNotEmpty) {
            foods = await _validateWithUSDA(foods);
          }
        } catch (e) {
          LoggingService.warn('FoodScannerBloc', 'Gemini falhou: $e');
        }
      }

      if (foods.isEmpty) {
        try {
          foods = await _aiFoodService.analyzeFoodFromText(event.text);
          LoggingService.info('FoodScannerBloc', 'AiFoodService retornou ${foods.length} alimentos');
        } catch (e) {
          LoggingService.error('FoodScannerBloc', 'Todos os serviços falharam', e);
        }
      }

      if (foods.isEmpty) {
        emit(
          const FoodScannerError(
            'Não foi possível identificar os alimentos. Tente ser mais específico.',
          ),
        );
      } else {
        emit(FoodScannerAnalyzed(scannedFoods: foods, selectedFoods: const []));
      }
    } catch (e) {
      LoggingService.error('FoodScannerBloc', 'AnalyzeText', e);
      emit(
        const FoodScannerError(
          'Erro ao buscar alimento. Verifique sua conexão e tente novamente.',
        ),
      );
    }
  }

  Future<void> _onSearchFoodByName(
    SearchFoodByName event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(FoodScannerLoading());
    try {
      List<FoodItem> foods = [];

      try {
        foods = await _usdaFoodService.searchFoodByName(event.query);
        LoggingService.info('FoodScannerBloc', 'USDA retornou ${foods.length} alimentos');
      } catch (e) {
        LoggingService.warn('FoodScannerBloc', 'USDA falhou: $e');
      }

      if (foods.isEmpty) {
        try {
          foods = await _geminiFoodService.analyzeFoodFromText(event.query);
          LoggingService.info('FoodScannerBloc', 'Gemini retornou ${foods.length} alimentos');
          if (foods.isNotEmpty) {
            foods = await _validateWithUSDA(foods);
          }
        } catch (e) {
          LoggingService.warn('FoodScannerBloc', 'Gemini falhou: $e');
        }
      }

      if (foods.isEmpty) {
        try {
          foods = await _fatSecretService.searchFoods(event.query);
          LoggingService.info('FoodScannerBloc', 'FatSecret retornou ${foods.length} alimentos');
        } catch (e) {
          LoggingService.warn('FoodScannerBloc', 'FatSecret falhou: $e');
        }
      }

      if (foods.isEmpty) {
        try {
          foods = await _aiFoodService.analyzeFoodFromText(event.query);
          if (foods.isEmpty) {
            foods = await _aiFoodService.searchOpenFoodFacts(event.query);
          }
          LoggingService.info('FoodScannerBloc', 'AiFoodService retornou ${foods.length} alimentos');
        } catch (e) {
          LoggingService.error('FoodScannerBloc', 'Todos os serviços falharam', e);
        }
      }

      if (foods.isEmpty) {
        emit(
          const FoodScannerError(
            'Nenhum alimento encontrado. Tente outro nome ou use a câmera para fotografar.',
          ),
        );
      } else {
        emit(FoodScannerAnalyzed(scannedFoods: foods, selectedFoods: const []));
      }
    } catch (e) {
      LoggingService.error('FoodScannerBloc', 'SearchFoodByName', e);
      emit(
        const FoodScannerError(
          'Erro ao buscar alimento. Verifique sua conexão e tente novamente.',
        ),
      );
    }
  }

  void _onClearScannedFoods(
    ClearScannedFoods event,
    Emitter<FoodScannerState> emit,
  ) {
    emit(FoodScannerInitial());
  }

  void _onSelectFood(SelectFood event, Emitter<FoodScannerState> emit) {
    final currentState = state;
    if (currentState is FoodScannerAnalyzed) {
      final isAlreadySelected = currentState.selectedFoods.any(
        (f) => f.id == event.food.id,
      );
      if (isAlreadySelected) return;
      final updatedSelected = [...currentState.selectedFoods, event.food];
      emit(currentState.copyWith(selectedFoods: updatedSelected));
    }
  }

  void _onDeselectFood(DeselectFood event, Emitter<FoodScannerState> emit) {
    final currentState = state;
    if (currentState is FoodScannerAnalyzed) {
      final updatedSelected = currentState.selectedFoods
          .where((f) => f.id != event.food.id)
          .toList();
      emit(currentState.copyWith(selectedFoods: updatedSelected));
    }
  }

  void _onUpdateFoodPortion(
    UpdateFoodPortion event,
    Emitter<FoodScannerState> emit,
  ) {
    final currentState = state;
    if (currentState is FoodScannerAnalyzed) {
      final updatedFoods = currentState.scannedFoods.map((f) {
        if (f.id == event.food.id) {
          return f.copyWith(portion: event.newPortion);
        }
        return f;
      }).toList();
      emit(currentState.copyWith(scannedFoods: updatedFoods));
    }
  }

  void _onRemoveSelectedFood(
    RemoveSelectedFood event,
    Emitter<FoodScannerState> emit,
  ) {
    final currentState = state;
    if (currentState is FoodScannerAnalyzed) {
      final updatedSelected = currentState.selectedFoods
          .where((f) => f.id != event.food.id)
          .toList();
      emit(currentState.copyWith(selectedFoods: updatedSelected));
    }
  }
}
