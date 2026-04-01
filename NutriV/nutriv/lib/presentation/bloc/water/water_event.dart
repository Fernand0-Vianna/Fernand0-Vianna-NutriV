import 'package:equatable/equatable.dart';

abstract class WaterEvent extends Equatable {
  const WaterEvent();

  @override
  List<Object?> get props => [];
}

class LoadWaterIntake extends WaterEvent {
  final DateTime date;

  const LoadWaterIntake(this.date);

  @override
  List<Object?> get props => [date];
}

class AddWater extends WaterEvent {
  final double amount;

  const AddWater(this.amount);

  @override
  List<Object?> get props => [amount];
}

class RemoveWater extends WaterEvent {
  final double amount;

  const RemoveWater(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SetWaterGoal extends WaterEvent {
  final double goal;

  const SetWaterGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class ResetWaterIntake extends WaterEvent {}

abstract class WaterState extends Equatable {
  const WaterState();

  @override
  List<Object?> get props => [];
}

class WaterInitial extends WaterState {}

class WaterLoading extends WaterState {}

class WaterLoaded extends WaterState {
  final DateTime date;
  final double currentIntake;
  final double goal;

  const WaterLoaded({
    required this.date,
    required this.currentIntake,
    required this.goal,
  });

  double get progress => (currentIntake / goal).clamp(0.0, 1.0);
  double get remaining => (goal - currentIntake).clamp(0.0, goal);

  @override
  List<Object?> get props => [date, currentIntake, goal];
}

class WaterError extends WaterState {
  final String message;

  const WaterError(this.message);

  @override
  List<Object?> get props => [message];
}
