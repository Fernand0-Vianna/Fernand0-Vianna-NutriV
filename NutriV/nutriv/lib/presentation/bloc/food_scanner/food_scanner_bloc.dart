import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/ai_food_service.dart';
import '../../../data/datasources/usda_food_service.dart';
import 'food_scanner_event.dart';
import 'food_scanner_state.dart';

class FoodScannerBloc extends Bloc<FoodScannerEvent, FoodScannerState> {
  final AiFoodService _aiFoodService;
  final UsdaFoodService _usdaFoodService;

  FoodScannerBloc(this._aiFoodService, this._usdaFoodService)
    : super(FoodScannerInitial()) {
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
      final foods = await _aiFoodService.analyzeFoodImage(event.imageFile);
      
      if (foods.isEmpty) {
        emit(
          const FoodScannerError(
            'Não foi possível identificar os alimentos. Tente novamente.',
          ),
        );
      } else {
        emit(FoodScannerAnalyzed(scannedFoods: foods));
      }
    } catch (e) {
      emit(FoodScannerError(e.toString()));
    }
  }

  Future<void> _onAnalyzeText(
    AnalyzeText event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(FoodScannerLoading());
    try {
      final foods = await _aiFoodService.analyzeFoodFromText(event.text);
      if (foods.isEmpty) {
        emit(
          const FoodScannerError(
            'Não foi possível identificar os alimentos. Tente novamente.',
          ),
        );
      } else {
        emit(FoodScannerAnalyzed(scannedFoods: foods));
      }
    } catch (e) {
      emit(FoodScannerError(e.toString()));
    }
  }

  Future<void> _onSearchFoodByName(
    SearchFoodByName event,
    Emitter<FoodScannerState> emit,
  ) async {
    emit(FoodScannerLoading());
    try {
      var foods = await _usdaFoodService.searchFoodByName(event.query);
      
      if (foods.isEmpty) {
        foods = await _aiFoodService.analyzeFoodFromText(event.query);
      }
      
      if (foods.isEmpty) {
        foods = await _aiFoodService.searchOpenFoodFacts(event.query);
      }
      
      if (foods.isEmpty) {
        emit(
          const FoodScannerError(
            'Nenhum alimento encontrado. Tente outro nome ou use a câmera.',
          ),
        );
      } else {
        emit(FoodScannerAnalyzed(scannedFoods: foods));
      }
    } catch (e) {
      emit(FoodScannerError(e.toString()));
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
