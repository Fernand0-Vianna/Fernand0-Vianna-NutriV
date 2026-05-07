import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../database/database_helper.dart';

class ActivityData {
  final int steps;
  final double distanceKm;
  final int caloriesBurned;
  final double activeMinutes;
  final DateTime timestamp;

  ActivityData({
    required this.steps,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.timestamp,
  });
}

class ActivityService {
  final DatabaseHelper _db;

  int _todaySteps = 0;
  int _goalSteps = 10000;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _sessionSteps = 0;
  double _lastMagnitude = 0;
  bool _isTracking = false;

  static const double _stepThreshold = 12.0;
  static const double _caloriesPerStep = 0.04;

  ActivityService(this._db);

  Future<void> initialize() async {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    _todaySteps = await _db.getStepsForDate(dateStr);
    _goalSteps = await _db.getStepGoalForDate(dateStr);
  }

  int get todaySteps => _todaySteps;
  int get goalSteps => _goalSteps;
  bool get isTracking => _isTracking;

  double get progress => _goalSteps > 0 ? _todaySteps / _goalSteps : 0;

  int get caloriesBurned => (_todaySteps * _caloriesPerStep).toInt();

  double get distanceKm => _todaySteps * 0.0008;

  double get activeMinutes {
    final minutes = (_todaySteps / 100).clamp(0.0, 180.0);
    return minutes;
  }

  Future<void> _saveTodayData() async {
    final now = DateTime.now();
    final dateStr = _formatDate(now);
    await _db.saveSteps(date: dateStr, steps: _todaySteps, goal: _goalSteps);
  }

  void startTracking() {
    if (_isTracking) return;

    _isTracking = true;
    _sessionSteps = 0;

    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen(
      (AccelerometerEvent event) {
        _processAccelerometerData(event);
      },
      onError: (error) {
        _isTracking = false;
      },
    );
  }

  void _processAccelerometerData(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    ).toDouble();

    if (_lastMagnitude > _stepThreshold && magnitude < _stepThreshold) {
      if (magnitude < _lastMagnitude - 2) {
        _sessionSteps++;
      }
    }

    _lastMagnitude = magnitude;
  }

  void stopTracking() {
    if (!_isTracking) return;

    _isTracking = false;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    if (_sessionSteps > 0) {
      _todaySteps += _sessionSteps.toInt();
      _saveTodayData();
    }

    _sessionSteps = 0;
  }

  Future<void> addManualSteps(int steps) async {
    _todaySteps += steps;
    await _saveTodayData();
  }

  Future<void> updateSteps(int steps) async {
    _todaySteps = steps;
    await _saveTodayData();
  }

  Future<void> setStepGoal(int goal) async {
    _goalSteps = goal;
    await _db.setStepGoal(goal);
  }

  Future<List<ActivityData>> getWeeklyActivity() async {
    final dbResults = await _db.getWeeklySteps();
    final weekData = <ActivityData>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final entry = dbResults.where((e) => e['date'] == dateStr).toList();
      final steps = entry.isNotEmpty
          ? (entry.first['steps'] as num).toInt()
          : 0;

      weekData.add(ActivityData(
        steps: steps,
        distanceKm: steps * 0.0008,
        caloriesBurned: (steps * _caloriesPerStep).toInt(),
        activeMinutes: (steps / 100).clamp(0, 180),
        timestamp: date,
      ));
    }

    return weekData;
  }

  Future<Map<String, dynamic>> getWeeklyStats() async {
    final weekData = await getWeeklyActivity();
    final totalSteps =
        weekData.fold<int>(0, (sum, data) => sum + data.steps);
    final avgSteps = weekData.isNotEmpty ? totalSteps ~/ weekData.length : 0;
    final totalCalories =
        weekData.fold<int>(0, (sum, data) => sum + data.caloriesBurned);

    return {
      'totalSteps': totalSteps,
      'averageSteps': avgSteps,
      'totalCalories': totalCalories,
      'totalDistance': (totalSteps * 0.0008),
      'daysGoalMet': weekData.where((d) => d.steps >= 10000).length,
    };
  }

  Future<int> getStreak() async {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final steps = await _db.getStepsForDate(dateStr);

      if (steps >= _goalSteps) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return streak;
  }

  double estimateCaloriesFromActivity(int steps, int activeMinutes) {
    final stepCalories = steps * _caloriesPerStep;
    final activityCalories = activeMinutes * 5;
    return stepCalories + activityCalories;
  }

  void dispose() {
    stopTracking();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
