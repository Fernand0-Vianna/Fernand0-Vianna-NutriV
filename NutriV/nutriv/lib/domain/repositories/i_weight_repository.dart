import '../../data/repositories/weight_repository.dart';

abstract class IWeightRepository {
  Future<WeightLogData> addWeight(WeightLogData weight);
  Future<List<WeightLogData>> getWeightHistory({int days = 30});
  Future<WeightLogData?> getLatestWeight();
  Future<WeightLogData?> getWeightForDate(DateTime date);
  Future<void> updateWeight(String id, WeightLogData weight);
  Future<void> deleteWeight(String id);
  Future<Map<String, dynamic>?> getProgress();
  Stream<List<WeightLogData>> watchWeightHistory();
}
