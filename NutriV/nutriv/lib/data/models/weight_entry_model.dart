import '../../domain/entities/weight_entry.dart';

class WeightEntryModel extends WeightEntry {
  const WeightEntryModel({
    required super.id,
    required super.weight,
    required super.date,
    super.notes,
  });

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) {
    return WeightEntryModel(
      id: json['id'] as String,
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory WeightEntryModel.fromEntity(WeightEntry entry) {
    return WeightEntryModel(
      id: entry.id,
      weight: entry.weight,
      date: entry.date,
      notes: entry.notes,
    );
  }
}
