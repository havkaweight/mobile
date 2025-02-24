import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/health/health_data.dart';
import '../../../domain/repositories/health/health_repository.dart';
import '../../models/health/health_data_model.dart';

class HealthRepositoryImpl implements HealthRepository {
  final Health _health = Health();
  static const String _syncKey = "health_sync_enabled";

  @override
  Future<bool> isSynced() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncKey) ?? false;
  }

  @override
  Future<void> enableSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncKey, true);
  }

  @override
  Future<void> disableSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncKey, false);
  }

  @override
  Future<bool> requestPermissions() async {
    return await _health.requestAuthorization([HealthDataType.WEIGHT]);
  }

  @override
  Future<List<HealthData>> fetchWeightHistory(
      DateTime start, DateTime end) async {
    final data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.WEIGHT],
      startTime: start,
      endTime: end,
    );

    return data
        .map((entry) {
          final parsedData = entry.toJson();
          return HealthDataModel.fromJson(parsedData).toEntity();;
    })
        .toList();
  }

  @override
  Future<HealthData?> getLatestWeight() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(Duration(days: 7));

    final data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.WEIGHT],
      startTime: now,
      endTime: lastWeek,
    );

    if (data.isNotEmpty) {
      final parsedData = data.last.toJson();
      return HealthDataModel.fromJson(parsedData).toEntity();
    }
    return null;
  }

  @override
  Future<void> addWeight(double weight) async {
    final now = DateTime.now();
    await _health.writeHealthData(
      value: weight,
      type: HealthDataType.WEIGHT,
      startTime: now,
      endTime: now,
    );
  }
}
