import '../../entities/health/health_data.dart';

abstract class HealthRepository {
  Future<bool> isSynced();
  Future<void> enableSync();
  Future<void> disableSync();
  Future<bool> requestPermissions();
  Future<List<HealthData>> fetchWeightHistory(DateTime start, DateTime end);
  Future<HealthData?> getLatestWeight();
  Future<void> addWeight(double weight);
}
