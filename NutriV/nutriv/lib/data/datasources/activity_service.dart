import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  final SharedPreferences _prefs;

  int _todaySteps = 0;
  int _goalSteps = 10000;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double _sessionSteps = 0;
  double _lastMagnitude = 0;
  bool _isTracking = false;

  static const double _stepThreshold = 12.0;
  static const double _caloriesPerStep = 0.04;

  ActivityService(this._prefs) {
    _loadTodayData();
    _goalSteps = _prefs.getInt('step_goal') ?? 10000;
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

  void _loadTodayData() {
    final now = DateTime.now();
    final key = 'steps_${now.year}-${now.month}-${now.day}';
    _todaySteps = _prefs.getInt(key) ?? 0;
  }

  Future<void> _saveTodayData() async {
    final now = DateTime.now();
    final key = 'steps_${now.year}-${now.month}-${now.day}';
    await _prefs.setInt(key, _todaySteps);
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
    await _prefs.setInt('step_goal', goal);
  }

  List<ActivityData> getWeeklyActivity() {
    final weekData = <ActivityData>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = 'steps_${date.year}-${date.month}-${date.day}';
      final steps = _prefs.getInt(key) ?? 0;

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

  Map<String, dynamic> getWeeklyStats() {
    final weekData = getWeeklyActivity();
    final totalSteps = weekData.fold<int>(0, (sum, data) => sum + data.steps);
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

  int getStreak() {
    int streak = 0;
    final now = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final key = 'steps_${date.year}-${date.month}-${date.day}';
      final steps = _prefs.getInt(key) ?? 0;

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
}
