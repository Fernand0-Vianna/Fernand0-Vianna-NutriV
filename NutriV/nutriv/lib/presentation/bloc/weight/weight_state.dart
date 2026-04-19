part of 'weight_bloc.dart';

abstract class WeightState extends Equatable {
  const WeightState();

  @override
  List<Object?> get props => [];
}

class WeightInitial extends WeightState {}

class WeightLoading extends WeightState {}

class WeightLoaded extends WeightState {
  final List<WeightLogData> history;
  final Map<String, dynamic>? progress;

  const WeightLoaded({
    required this.history,
    this.progress,
  });

  @override
  List<Object?> get props => [history, progress];
}

class WeightError extends WeightState {
  final String message;

  const WeightError(this.message);

  @override
  List<Object?> get props => [message];
}