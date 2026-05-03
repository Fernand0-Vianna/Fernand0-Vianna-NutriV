import 'package:shared_preferences/shared_preferences.dart';

class PedometerService {
  final SharedPreferences _prefs;
  int _todaySteps = 0;
  int _goalSteps = 10000;

  PedometerService(this._prefs) {
    _loadTodaySteps();
    _goalSteps = _prefs.getInt('step_goal') ?? 10000;
  }

  int get todaySteps => _todaySteps;
  int get goalSteps => _goalSteps;

  double get progress => _goalSteps > 0 ? _todaySteps / _goalSteps : 0;

  void _loadTodaySteps() {
    final today = DateTime.now();
    final key = 'steps_${today.year}-${today.month}-${today.day}';
    _todaySteps = _prefs.getInt(key) ?? 0;
  }

  Future<void> _saveTodaySteps() async {
    final today = DateTime.now();
    final key = 'steps_${today.year}-${today.month}-${today.day}';
    await _prefs.setInt(key, _todaySteps);
  }

  Future<void> addSteps(int steps) async {
    _todaySteps += steps;
    await _saveTodaySteps();
  }

  Future<void> updateSteps(int steps) async {
    _todaySteps = steps;
    await _saveTodaySteps();
  }

  Future<void> setStepGoal(int goal) async {
    _goalSteps = goal;
    await _prefs.setInt('step_goal', goal);
  }

  List<int> getWeeklySteps() {
    final weekSteps = <int>[];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = 'steps_${date.year}-${date.month}-${date.day}';
      weekSteps.add(_prefs.getInt(key) ?? 0);
    }

    return weekSteps;
  }

  int getWeeklyAverage() {
    final weekSteps = getWeeklySteps();
    if (weekSteps.isEmpty) return 0;
    return weekSteps.reduce((a, b) => a + b) ~/ weekSteps.length;
  }

  int getTotalWeeklySteps() {
    return getWeeklySteps().reduce((a, b) => a + b);
  }
}
