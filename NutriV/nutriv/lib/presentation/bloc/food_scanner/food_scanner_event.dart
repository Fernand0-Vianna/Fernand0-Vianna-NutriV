import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/food_item.dart';

abstract class FoodScannerEvent extends Equatable {
  const FoodScannerEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeImage extends FoodScannerEvent {
  final File imageFile;

  const AnalyzeImage(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

class AnalyzeText extends FoodScannerEvent {
  final String text;

  const AnalyzeText(this.text);

  @override
  List<Object?> get props => [text];
}

class SearchFoodByName extends FoodScannerEvent {
  final String query;

  const SearchFoodByName(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearScannedFoods extends FoodScannerEvent {}

class SelectFood extends FoodScannerEvent {
  final FoodItem food;

  const SelectFood(this.food);

  @override
  List<Object?> get props => [food];
}

class UpdateFoodPortion extends FoodScannerEvent {
  final FoodItem food;
  final double newPortion;

  const UpdateFoodPortion({required this.food, required this.newPortion});

  @override
  List<Object?> get props => [food, newPortion];
}

class RemoveSelectedFood extends FoodScannerEvent {
  final FoodItem food;

  const RemoveSelectedFood(this.food);

  @override
  List<Object?> get props => [food];
}

class DeselectFood extends FoodScannerEvent {
  final FoodItem food;

  const DeselectFood(this.food);

  @override
  List<Object?> get props => [food];
}
