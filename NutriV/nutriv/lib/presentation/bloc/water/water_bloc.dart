import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/database_helper.dart';
import 'water_event.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final DatabaseHelper _db;

  WaterBloc(this._db) : super(WaterInitial()) {
    on<LoadWaterIntake>(_onLoadWaterIntake);
    on<AddWater>(_onAddWater);
    on<RemoveWater>(_onRemoveWater);
    on<SetWaterGoal>(_onSetWaterGoal);
    on<ResetWaterIntake>(_onResetWaterIntake);
  }

  Future<void> _onLoadWaterIntake(
    LoadWaterIntake event,
    Emitter<WaterState> emit,
  ) async {
    emit(WaterLoading());
    try {
      final dateStr = _formatDate(event.date);
      final data = await _db.getWaterIntakeForDate(dateStr);
      final goal = await _db.getWaterGoal();
      emit(
        WaterLoaded(date: event.date, currentIntake: data, goal: goal),
      );
    } catch (e) {
      emit(WaterError(e.toString()));
    }
  }

  Future<void> _onAddWater(AddWater event, Emitter<WaterState> emit) async {
    final currentState = state;
    if (currentState is WaterLoaded) {
      final newIntake = currentState.currentIntake + event.amount;
      final dateStr = _formatDate(currentState.date);
      await _db.addWaterIntake({
        'id':
            '${dateStr}_${DateTime.now().millisecondsSinceEpoch}',
        'date': dateStr,
        'amount_ml': event.amount,
        'consumed_at': DateTime.now().toIso8601String(),
      });
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
      final newIntake = (currentState.currentIntake - event.amount)
          .clamp(0.0, double.infinity);
      final dateStr = _formatDate(currentState.date);
      final history = await _db.getWaterIntakeHistory(days: 1);
      if (history.isNotEmpty) {
        final lastEntry = history.first;
        if (lastEntry['total'] != null) {
          final existingTotal =
              (lastEntry['total'] as num).toDouble();
          if (existingTotal > 0) {
            final entryId =
                '${dateStr}_${DateTime.now().millisecondsSinceEpoch}';
            await _db.addWaterIntake({
              'id': entryId,
              'date': dateStr,
              'amount_ml': -event.amount,
              'consumed_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }
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
    final profile = await _db.getUserProfile();
    if (profile != null) {
      profile['water_goal'] = event.goal;
      await _db.saveUserProfile(profile);
    }
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
      final dateStr = _formatDate(currentState.date);
      await _db.addWaterIntake({
        'id':
            '${dateStr}_${DateTime.now().millisecondsSinceEpoch}',
        'date': dateStr,
        'amount_ml': -currentState.currentIntake,
        'consumed_at': DateTime.now().toIso8601String(),
      });
      emit(
        WaterLoaded(
          date: currentState.date,
          currentIntake: 0,
          goal: currentState.goal,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
