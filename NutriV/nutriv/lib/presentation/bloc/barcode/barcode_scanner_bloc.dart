import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/food_item.dart';
import 'barcode_scanner_event.dart';
import 'barcode_scanner_state.dart';

class BarcodeScannerBloc
    extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
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
    final food = _searchLocalDatabase(event.barcode);

    if (food != null) {
      emit(BarcodeScannerSuccess(barcode: event.barcode, food: food));
    } else {
      emit(BarcodeNotFound(event.barcode));
    }
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
