import '../../data/repositories/water_repository.dart';

abstract class IWaterRepository {
  Future<WaterIntakeData> addWater(WaterIntakeData water);
  Future<List<WaterIntakeData>> getWaterForDate(DateTime date);
  Future<double> getTotalWaterForDate(DateTime date);
  Future<void> deleteWater(String id);
  Stream<List<WaterIntakeData>> watchWaterForDate(DateTime date);
}
