import '../database/database_helper.dart';

class PedometerService {
  final DatabaseHelper _db;
  int _todaySteps = 0;
  int _goalSteps = 10000;

  PedometerService(this._db);

  Future<void> initialize() async {
    final today = DateTime.now();
    final dateStr = _formatDate(today);
    _todaySteps = await _db.getStepsForDate(dateStr);
    _goalSteps = await _db.getStepGoalForDate(dateStr);
  }

  int get todaySteps => _todaySteps;
  int get goalSteps => _goalSteps;

  double get progress => _goalSteps > 0 ? _todaySteps / _goalSteps : 0;

  Future<void> _saveTodaySteps() async {
    final today = DateTime.now();
    final dateStr = _formatDate(today);
    await _db.saveSteps(date: dateStr, steps: _todaySteps, goal: _goalSteps);
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
    await _db.setStepGoal(goal);
  }

  Future<List<int>> getWeeklySteps() async {
    final dbResults = await _db.getWeeklySteps();
    final weekSteps = <int>[];
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      final dateStr = _formatDate(date);
      final entry = dbResults.where((e) => e['date'] == dateStr).toList();
      weekSteps.add(entry.isNotEmpty
          ? (entry.first['steps'] as num).toInt()
          : 0);
    }

    return weekSteps;
  }

  Future<int> getWeeklyAverage() async {
    final weekSteps = await getWeeklySteps();
    if (weekSteps.isEmpty) return 0;
    return weekSteps.reduce((a, b) => a + b) ~/ weekSteps.length;
  }

  Future<int> getTotalWeeklySteps() async {
    final weekSteps = await getWeeklySteps();
    if (weekSteps.isEmpty) return 0;
    return weekSteps.reduce((a, b) => a + b);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
