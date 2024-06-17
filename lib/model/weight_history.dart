import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';

import '../ui/screens/authorization.dart';
import 'data_items.dart';

class WeightHistoryDataModel extends ChangeNotifier {
  List<DataPoint> _data = [];
  List<DataPoint> get data => _data;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  bool? _isSynced = true;
  bool? get isSynced => _isSynced;

  WeightHistoryDataModel() {
    checkSync();
    if(_isSynced != null && _isSynced!) {
      initData();
    }
  }

  Health _health = Health();

  static final _types = [
    HealthDataType.WEIGHT,
  ];

  static final _check_permissions = _types.map((e) => HealthDataAccess.WRITE).toList();
  static final _request_permissions = _types.map((e) => HealthDataAccess.READ_WRITE).toList();

  Future<void> checkSync() async {
    _isSynced = await _health.hasPermissions(_types, permissions: _check_permissions);
    notifyListeners();
  }

  Future<void> initData() async {
    _isLoaded = false;
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_weight_history-$userId.json";
    final Directory dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync()) as List;
      _data = jsonData.map<DataPoint>(
            (json) => DataPoint.fromJson(json as Map<String, dynamic>)).toList();
      _isLoaded = true;
      notifyListeners();
    }

    List<HealthDataPoint> _healthDataList = [];
    final now = DateTime.now();
    final firstDate = now.subtract(Duration(days: 28));
    try {
      List<HealthDataPoint> healthData =
      await _health.getHealthDataFromTypes(
          startTime: firstDate,
          endTime: now,
          types: _types);
      _healthDataList.addAll(
          (healthData.length < 100) ? healthData : healthData.sublist(0, 100));
    } catch (error) {
      print("Exception in getHealthDataFromTypes: $error");
    }
    if (_healthDataList.isEmpty) {
      return;
    }
    _healthDataList.sort((a, b) => a.dateTo.compareTo(b.dateTo));
    _data.clear();
    _healthDataList.sort((a, b) => a.dateTo.compareTo(b.dateTo));
    _healthDataList.forEach((el) => _data
        .add(DataPoint(el.dateTo, el.value.toJson()["numeric_value"])));
    file.writeAsStringSync(
      jsonEncode(_data.map((e) => e.toJson()).toList()),
      flush: true,
    );
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> requestAccess() async {
    _isLoaded = false;
    try {
      await _health.requestAuthorization(_types, permissions: _request_permissions);
      await checkSync();
      if(_isSynced != null && _isSynced!) {
        initData();
      }
    } catch (error) {
      print("Exception in authorize: $error");
    }
    _isLoaded = true;
    notifyListeners();
  }

  void addWeight(DataPoint value) {
    _data.add(value);
    notifyListeners();
  }

  DataPoint getLastWeight() {
    if(_data.isEmpty) {
      return DataPoint(DateTime.now(), 0);
    }
    return _data.sorted((a, b) => a.dx.compareTo(b.dx)).last;
  }
}