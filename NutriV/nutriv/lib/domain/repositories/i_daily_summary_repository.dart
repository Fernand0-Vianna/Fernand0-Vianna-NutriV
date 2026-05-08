import '../../data/repositories/daily_summary_repository.dart';

abstract class IDailySummaryRepository {
  Future<DailySummaryData?> getSummaryForDate(DateTime date);
  Future<List<DailySummaryData>> getSummariesForRange(DateTime start, DateTime end);
  Future<void> recalculateSummary(DateTime date);
  Stream<DailySummaryData?> watchTodaySummary();
  Stream<DailySummaryData?> watchSummaryForDate(DateTime date);
  Stream<List<DailySummaryData>> watchWeeklySummary();
  Future<Map<String, dynamic>> getWeeklyStats();
}
