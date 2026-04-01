import '../../domain/entities/daily_log.dart';
import '../datasources/local_data_source.dart';
import '../models/daily_log_model.dart';

class DailyLogRepository {
  final LocalDataSource _localDataSource;

  DailyLogRepository(this._localDataSource);

  Future<void> saveDailyLog(DailyLog dailyLog) async {
    await _localDataSource.saveDailyLog(DailyLogModel.fromEntity(dailyLog));
  }

  DailyLog? getDailyLogByDate(DateTime date) {
    return _localDataSource.getDailyLogByDate(date);
  }

  List<DailyLog> getDailyLogs() {
    return _localDataSource.getDailyLogs();
  }

  List<DailyLog> getDailyLogsForRange(DateTime start, DateTime end) {
    final logs = getDailyLogs();
    return logs
        .where(
          (l) =>
              l.date.isAfter(start.subtract(const Duration(days: 1))) &&
              l.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }
}
