import 'package:equatable/equatable.dart';

class FoodItem extends Equatable {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double portion;
  final String portionUnit;
  final String? imageUrl;
  final String? barcode;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    required this.portion,
    this.portionUnit = 'g',
    this.imageUrl,
    this.barcode,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    double? sodium,
    double? portion,
    String? portionUnit,
    String? imageUrl,
    String? barcode,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      portion: portion ?? this.portion,
      portionUnit: portionUnit ?? this.portionUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        calories,
        protein,
        carbs,
        fat,
        fiber,
        sugar,
        sodium,
        portion,
        portionUnit,
        imageUrl,
        barcode,
      ];
}
