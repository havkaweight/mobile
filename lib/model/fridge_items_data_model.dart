import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import '../model/user.dart';
import '../ui/screens/authorization.dart';
import 'data_items.dart';
import 'fridge.dart';

class FridgeDataModel extends ChangeNotifier {
  List<UserFridge> _fridgeData = [];
  List<UserFridge> get fridgeData => _fridgeData;

  UserFridge? _mainFridge = null;
  UserFridge? get mainFridge => _mainFridge;

  List<UserFridgeItem> _fridgeItemsData = [];
  List<UserFridgeItem> get fridgeItemsData => _fridgeItemsData;

  FridgeDataModel() {
    initData();
  }

  void set fridgeData(List<UserFridge> newFridgeData) {
    if(_fridgeData != newFridgeData) {
     _fridgeData = newFridgeData;
    }
  }

  void set mainFridge(UserFridge? newFridge) {
    if(_mainFridge != newFridge) {
      _mainFridge = newFridge;
    }
  }

  Future<void> initData() async {
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_fridges-$userId.json";
    final Directory dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync()) as List;
      _fridgeData = jsonData.map((json) => UserFridge.fromJson(json)).toList();
      print(_fridgeData);
      _mainFridge = _fridgeData.first;
      print(_mainFridge);

      final String fridgeItemsFileName = "user_fridge_items-$userId-${_mainFridge!.id}.json";
      final File fridgeItemsFile = File("${dir.path}/$fridgeItemsFileName");
      if (fridgeItemsFile.existsSync()) {
        final fridgeItemsJsonData = jsonDecode(fridgeItemsFile.readAsStringSync()) as Iterable;
        _fridgeItemsData = fridgeItemsJsonData.map((json) => UserFridgeItem.fromJson(json)).toList();
      }
      notifyListeners();
    }

    _fridgeData = await ApiRoutes().getUserFridges();
    _mainFridge = _fridgeData.first;

    final String fridgeItemsFileName = "user_fridge_items-$userId-${_mainFridge!.id}.json";
    final File fridgeItemsFile = File("${dir.path}/$fridgeItemsFileName");
    if (fridgeItemsFile.existsSync()) {
      final fridgeItemsJsonData = jsonDecode(fridgeItemsFile.readAsStringSync()) as List;
      _fridgeItemsData = fridgeItemsJsonData.map((json) => UserFridgeItem.fromJson(json)).toList();
    }

    file.writeAsStringSync(
      jsonEncode(_fridgeData.map((e) => e.toJson()).toList()),
      flush: true,
    );

    fridgeItemsFile.writeAsStringSync(
      jsonEncode(_fridgeItemsData.map((e) => e.toJson()).toList()),
      flush: true,
    );

    notifyListeners();
  }

  void addUserFridge(UserFridge uf) async {
    _fridgeData.add(uf);
    notifyListeners();
  }

  UserFridge getFirstUserFridge() {
    return _fridgeData.first;
  }

  void addUserFridgeItem(UserFridgeItem ufi) async {
    _fridgeItemsData.insert(0, ufi);
    notifyListeners();
  }

  void modifyUserFridge(UserFridge uf) async {
    _fridgeData.first = uf;
    notifyListeners();
  }
}