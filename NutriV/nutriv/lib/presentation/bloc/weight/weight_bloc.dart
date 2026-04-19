import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/weight_repository.dart';

part 'weight_event.dart';
part 'weight_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepository _repository;

  WeightBloc(this._repository) : super(WeightInitial()) {
    on<LoadWeightHistory>(_onLoadWeightHistory);
    on<AddWeightEntry>(_onAddWeightEntry);
    on<DeleteWeightEntry>(_onDeleteWeightEntry);
  }

  Future<void> _onLoadWeightHistory(
    LoadWeightHistory event,
    Emitter<WeightState> emit,
  ) async {
    emit(WeightLoading());
    try {
      final history = await _repository.getWeightHistory(days: event.days ?? 30);
      final progress = await _repository.getProgress();
      emit(WeightLoaded(
        history: history,
        progress: progress,
      ));
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }

  Future<void> _onAddWeightEntry(
    AddWeightEntry event,
    Emitter<WeightState> emit,
  ) async {
    try {
      await _repository.addWeight(event.weight);
      add(LoadWeightHistory());
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }

  Future<void> _onDeleteWeightEntry(
    DeleteWeightEntry event,
    Emitter<WeightState> emit,
  ) async {
    try {
      await _repository.deleteWeight(event.id);
      add(LoadWeightHistory());
    } catch (e) {
      emit(WeightError(e.toString()));
    }
  }
}