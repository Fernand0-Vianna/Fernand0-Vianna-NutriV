class FavoriteDishModel {
  final String? id;
  final String name;
  final List<FavoriteDishItem> items;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int timesUsed;
  final DateTime createdAt;
  final DateTime updatedAt;

  FavoriteDishModel({
    this.id,
    required this.name,
    required this.items,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    this.timesUsed = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FavoriteDishModel.fromJson(Map<String, dynamic> json) {
    return FavoriteDishModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => FavoriteDishItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      totalCalories: (json['total_calories'] as num?)?.toDouble() ?? 0,
      totalProtein: (json['total_protein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (json['total_carbs'] as num?)?.toDouble() ?? 0,
      totalFat: (json['total_fat'] as num?)?.toDouble() ?? 0,
      timesUsed: json['times_used'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((i) => i.toJson()).toList(),
      'total_calories': totalCalories,
      'total_protein': totalProtein,
      'total_carbs': totalCarbs,
      'total_fat': totalFat,
      'times_used': timesUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class FavoriteDishItem {
  final String? foodId;
  final String foodName;
  final double quantityG;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  FavoriteDishItem({
    this.foodId,
    required this.foodName,
    required this.quantityG,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory FavoriteDishItem.fromJson(Map<String, dynamic> json) {
    return FavoriteDishItem(
      foodId: json['food_id'] as String?,
      foodName: json['food_name'] as String,
      quantityG: (json['quantity_g'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      'quantity_g': quantityG,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fat_g': fatG,
    };
  }
}