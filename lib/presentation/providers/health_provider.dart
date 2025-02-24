import 'package:flutter/material.dart';
import '../../domain/entities/health/health_data.dart';
import '../../domain/repositories/health/health_repository.dart';

class HealthProvider extends ChangeNotifier {
  final HealthRepository _repository;
  HealthData? _latestWeight;
  List<HealthData> _weightHistory = [];
  bool _isSynced = false;

  HealthProvider(this._repository) {
    _checkSyncStatus();
  }

  HealthData? get latestWeight => _latestWeight;
  List<HealthData> get weightHistory => _weightHistory;
  bool get isSynced => _isSynced;

  Future<void> _checkSyncStatus() async {
    _isSynced = await _repository.isSynced();
    if (_isSynced) {
      await fetchWeightData();
    }
    notifyListeners();
  }

  Future<void> enableSync() async {
    if (await _repository.requestPermissions()) {
      await _repository.enableSync();
      _isSynced = true;
      await fetchWeightData();
    }
  }

  Future<void> disableSync() async {
    await _repository.disableSync();
    _isSynced = false;
    _latestWeight = null;
    _weightHistory = [];
    notifyListeners();
  }

  Future<void> fetchWeightData() async {
    if (!_isSynced) return;

    _latestWeight = await _repository.getLatestWeight();
    _weightHistory = await _repository.fetchWeightHistory(
      DateTime.now().subtract(Duration(days: 30)),
      DateTime.now(),
    );

    notifyListeners();
  }

  Future<void> addWeight(double weight) async {
    if (!_isSynced) return;

    await _repository.addWeight(weight);
    await fetchWeightData();
  }
}
