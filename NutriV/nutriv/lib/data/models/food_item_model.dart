import '../../domain/entities/food_item.dart';

class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    super.fiber,
    super.sugar,
    super.sodium,
    required super.portion,
    super.portionUnit,
    super.imageUrl,
    super.barcode,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      portion: (json['portion'] as num).toDouble(),
      portionUnit: json['portionUnit'] as String? ?? 'g',
      imageUrl: json['imageUrl'] as String?,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
      'portion': portion,
      'portionUnit': portionUnit,
      'imageUrl': imageUrl,
      'barcode': barcode,
    };
  }

  factory FoodItemModel.fromEntity(FoodItem food) {
    return FoodItemModel(
      id: food.id,
      name: food.name,
      calories: food.calories,
      protein: food.protein,
      carbs: food.carbs,
      fat: food.fat,
      fiber: food.fiber,
      sugar: food.sugar,
      sodium: food.sodium,
      portion: food.portion,
      portionUnit: food.portionUnit,
      imageUrl: food.imageUrl,
      barcode: food.barcode,
    );
  }

  factory FoodItemModel.fromAiResponse(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['food_name'] ?? json['name'] ?? 'Alimento',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0,
      portion: (json['portion_size'] as num?)?.toDouble() ?? 100,
      portionUnit: json['portion_unit'] ?? 'g',
    );
  }
}
