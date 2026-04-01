import 'package:equatable/equatable.dart';

class WeightEntry extends Equatable {
  final String id;
  final double weight;
  final DateTime date;
  final String? notes;

  const WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    this.notes,
  });

  WeightEntry copyWith({
    String? id,
    double? weight,
    DateTime? date,
    String? notes,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, weight, date, notes];
}
