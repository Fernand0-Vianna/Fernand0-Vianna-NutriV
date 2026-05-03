part of 'weight_bloc.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeightHistory extends WeightEvent {
  final int? days;

  const LoadWeightHistory({this.days});

  @override
  List<Object?> get props => [days];
}

class AddWeightEntry extends WeightEvent {
  final WeightLogData weight;

  const AddWeightEntry(this.weight);

  @override
  List<Object?> get props => [weight];
}

class DeleteWeightEntry extends WeightEvent {
  final String id;

  const DeleteWeightEntry(this.id);

  @override
  List<Object?> get props => [id];
}
