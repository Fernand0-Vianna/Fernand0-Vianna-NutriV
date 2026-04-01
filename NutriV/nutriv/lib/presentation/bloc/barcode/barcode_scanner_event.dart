import 'package:equatable/equatable.dart';

abstract class BarcodeScannerEvent extends Equatable {
  const BarcodeScannerEvent();

  @override
  List<Object?> get props => [];
}

class StartBarcodeScan extends BarcodeScannerEvent {}

class BarcodeDetected extends BarcodeScannerEvent {
  final String barcode;

  const BarcodeDetected(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class ClearBarcode extends BarcodeScannerEvent {}
