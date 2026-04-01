import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_item.dart';

abstract class FoodScannerState extends Equatable {
  const FoodScannerState();

  @override
  List<Object?> get props => [];
}

class FoodScannerInitial extends FoodScannerState {}

class FoodScannerLoading extends FoodScannerState {}

class FoodScannerAnalyzed extends FoodScannerState {
  final List<FoodItem> scannedFoods;
  final List<FoodItem> selectedFoods;

  const FoodScannerAnalyzed({
    required this.scannedFoods,
    this.selectedFoods = const [],
  });

  @override
  List<Object?> get props => [scannedFoods, selectedFoods];

  FoodScannerAnalyzed copyWith({
    List<FoodItem>? scannedFoods,
    List<FoodItem>? selectedFoods,
  }) {
    return FoodScannerAnalyzed(
      scannedFoods: scannedFoods ?? this.scannedFoods,
      selectedFoods: selectedFoods ?? this.selectedFoods,
    );
  }
}

class FoodScannerError extends FoodScannerState {
  final String message;

  const FoodScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
