import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_item.dart';

abstract class BarcodeScannerState extends Equatable {
  const BarcodeScannerState();

  @override
  List<Object?> get props => [];
}

class BarcodeScannerInitial extends BarcodeScannerState {}

class BarcodeScannerScanning extends BarcodeScannerState {}

class BarcodeScannerSuccess extends BarcodeScannerState {
  final String barcode;
  final FoodItem? food;

  const BarcodeScannerSuccess({required this.barcode, this.food});

  @override
  List<Object?> get props => [barcode, food];
}

class BarcodeScannerError extends BarcodeScannerState {
  final String message;

  const BarcodeScannerError(this.message);

  @override
  List<Object?> get props => [message];
}

class BarcodeNotFound extends BarcodeScannerState {
  final String barcode;

  const BarcodeNotFound(this.barcode);

  @override
  List<Object?> get props => [barcode];
}
