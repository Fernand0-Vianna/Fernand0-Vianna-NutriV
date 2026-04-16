import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'water_event.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final SharedPreferences _prefs;

  WaterBloc(this._prefs) : super(WaterInitial()) {
    on<LoadWaterIntake>(_onLoadWaterIntake);
    on<AddWater>(_onAddWater);
    on<RemoveWater>(_onRemoveWater);
    on<SetWaterGoal>(_onSetWaterGoal);
    on<ResetWaterIntake>(_onResetWaterIntake);
  }

  void _onLoadWaterIntake(LoadWaterIntake event, Emitter<WaterState> emit) {
    emit(WaterLoading());
    try {
      final data = _getWaterData(event.date);
      final goal = _getWaterGoal();
      emit(WaterLoaded(date: event.date, currentIntake: data, goal: goal));
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _onAddWater(AddWater event, Emitter<WaterState> emit) async {
    final currentState = state;
    if (currentState is WaterLoaded) {
      final newIntake = currentState.currentIntake + event.amount;
      await _saveWaterData(currentState.date, newIntake);
      emit(
        WaterLoaded(
          date: currentState.date,
          currentIntake: newIntake,
          goal: currentState.goal,
        ),
      );
    }
  }

  Future<void> _onRemoveWater(
    RemoveWater event,
    Emitter<WaterState> emit,
  ) async {
    final currentState = state;
    if (currentState is WaterLoaded) {
      final newIntake = (currentState.currentIntake - event.amount).clamp(
        0.0,
        double.infinity,
      );
      await _saveWaterData(currentState.date, newIntake);
      emit(
        WaterLoaded(
          date: currentState.date,
          currentIntake: newIntake,
          goal: currentState.goal,
        ),
      );
    }
  }

  Future<void> _onSetWaterGoal(
    SetWaterGoal event,
    Emitter<WaterState> emit,
  ) async {
    await _prefs.setDouble('water_goal', event.goal);
    final currentState = state;
    if (currentState is WaterLoaded) {
      emit(
        WaterLoaded(
          date: currentState.date,
          currentIntake: currentState.currentIntake,
          goal: event.goal,
        ),
      );
    }
  }

  Future<void> _onResetWaterIntake(
    ResetWaterIntake event,
    Emitter<WaterState> emit,
  ) async {
    final currentState = state;
    if (currentState is WaterLoaded) {
      await _saveWaterData(currentState.date, 0);
      emit(
        WaterLoaded(
          date: currentState.date,
          currentIntake: 0,
          goal: currentState.goal,
        ),
      );
    }
  }

  double _getWaterData(DateTime date) {
    final key = 'water_${date.year}_${date.month}_${date.day}';
    return _prefs.getDouble(key) ?? 0.0;
  }

  Future<void> _saveWaterData(DateTime date, double amount) async {
    final key = 'water_${date.year}_${date.month}_${date.day}';
    await _prefs.setDouble(key, amount);
  }

  double _getWaterGoal() {
    return _prefs.getDouble('water_goal') ?? 2000.0;
  }
}
