import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/colors.dart';
import '../model/user.dart';
import '../ui/screens/authorization.dart';
import 'data_items.dart';
import 'fridge.dart';

class FridgeDataModel extends ChangeNotifier {
  List<UserFridge> _fridgeData = List.empty(growable: true);
  List<UserFridge> get fridgeData => _fridgeData;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  UserFridge? _mainFridge = null;
  UserFridge? get mainFridge => _mainFridge;

  List<UserFridgeItem> _fridgeItemsData = List.empty(growable: true);
  List<UserFridgeItem> get fridgeItemsData => _fridgeItemsData;

  List<PFCDataItem> _fridgeNutrition = List.empty(growable: true);
  List<PFCDataItem> get fridgeNutrition => _fridgeNutrition;

  FridgeDataModel() {
    initData();
  }

  void set fridgeData(List<UserFridge> newFridgeData) {
    if(_fridgeData != newFridgeData) {
     _fridgeData = newFridgeData;
    }
    notifyListeners();
  }

  Future<void> setMainFridge(UserFridge? selectedFridge) async {
    if(_mainFridge != selectedFridge) {
      _mainFridge = selectedFridge;
      final token = await getToken();
      final userId = await getUserId(token);
      final String mainFridgeFileName = "main_fridge-$userId.json";
      final Directory dir = await getTemporaryDirectory();
      final File mainFridgeFile = File("${dir.path}/$mainFridgeFileName");
      mainFridgeFile.writeAsStringSync(
        jsonEncode(_mainFridge!.toJson()),
        flush: true,
      );
      notifyListeners();
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

      final String mainFridgeFileName = "main_fridge-$userId.json";
      final File mainFridgeFile = File("${dir.path}/$mainFridgeFileName");
      if (mainFridgeFile.existsSync()) {
        final mainFridgeJsonData = jsonDecode(mainFridgeFile.readAsStringSync());
        _mainFridge = UserFridge.fromJson(mainFridgeJsonData);
      } else {
        _mainFridge = _fridgeData.first;
      }

      final String fridgeItemsFileName = "user_fridge_items-$userId-${_mainFridge!.fridgeId}.json";
      final File fridgeItemsFile = File("${dir.path}/$fridgeItemsFileName");
      if (fridgeItemsFile.existsSync()) {
        final fridgeItemsJsonData = jsonDecode(fridgeItemsFile.readAsStringSync()) as Iterable;
        _fridgeItemsData = fridgeItemsJsonData.map((json) => UserFridgeItem.fromJson(json)).toList();
        _fridgeItemsData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      _isLoaded = true;
      _fridgeNutrition = await extractNutrition();
      notifyListeners();
    }

    _fridgeData = await ApiRoutes().getUserFridges();

    final String mainFridgeFileName = "main_fridge-$userId.json";
    final File mainFridgeFile = File("${dir.path}/$mainFridgeFileName");
    if (mainFridgeFile.existsSync()) {
      final mainFridgeJsonData = jsonDecode(mainFridgeFile.readAsStringSync());
      _mainFridge = UserFridge.fromJson(mainFridgeJsonData);
    } else {
      _mainFridge = _fridgeData.first;
    }

    _fridgeItemsData = await ApiRoutes().getUserFridgeItemsList(_mainFridge!);
    _fridgeItemsData.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    file.writeAsStringSync(
      jsonEncode(_fridgeData.map((e) => e.toJson()).toList()),
      flush: true,
    );

    if (mainFridgeFile.existsSync()) {} else {
      _mainFridge = _fridgeData.first;
    }
    mainFridgeFile.writeAsStringSync(
      jsonEncode(_mainFridge!.toJson()),
      flush: true,
    );

    final String fridgeItemsFileName = "user_fridge_items-$userId-${_mainFridge!.fridgeId}.json";
    final File fridgeItemsFile = File("${dir.path}/$fridgeItemsFileName");

    fridgeItemsFile.writeAsStringSync(
      jsonEncode(_fridgeItemsData.map((e) => e.toJson()).toList()),
      flush: true,
    );
    _isLoaded = true;

    _fridgeNutrition = await extractNutrition();
    notifyListeners();
  }

  void addUserFridge(UserFridge uf) async {
    _fridgeData.add(uf);
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_fridges-$userId.json";
    final Directory dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    file.writeAsStringSync(
      jsonEncode(_fridgeData.map((e) => e.toJson()).toList()),
      flush: true,
    );

    notifyListeners();
  }

  UserFridge getFirstUserFridge() {
    return _fridgeData.first;
  }

  Future<void> addUserFridgeItem(UserFridge uf, UserFridgeItem ufi) async {
    _fridgeItemsData.insert(0, ufi);

    final token = await getToken();
    final userId = await getUserId(token);

    final Directory dir = await getTemporaryDirectory();
    final String fridgeItemsFileName = "user_fridge_items-$userId-${uf.fridgeId}.json";
    final File fridgeItemsFile = File("${dir.path}/$fridgeItemsFileName");
    if (fridgeItemsFile.existsSync()) {
      fridgeItemsFile.writeAsStringSync(
        jsonEncode(_fridgeItemsData.map((e) => e.toJson()).toList()),
        flush: true,
      );
    }
    _fridgeNutrition = await extractNutrition();
    notifyListeners();
  }


  Future<void> deleteUserFridgeItem(UserFridgeItem ufi) async {
    final bool isDeleted = _fridgeItemsData.remove(ufi);

    if(!isDeleted) {
      return;
    }

    final token = await getToken();
    final userId = await getUserId(token);

    final Directory dir = await getTemporaryDirectory();
    final String fridgeItemsFileName = "user_fridge_items-$userId-${ufi.fridgeId}.json";
    final File fridgeItemsFile = File("${dir.path}/$fridgeItemsFileName");
    if (fridgeItemsFile.existsSync()) {
      fridgeItemsFile.writeAsStringSync(
        jsonEncode(_fridgeItemsData.map((e) => e.toJson()).toList()),
        flush: true,
      );
    }
    _fridgeNutrition = await extractNutrition();
    notifyListeners();
  }

  void reorder() {
    notifyListeners();
  }

  Future<void> modifyUserFridge(UserFridge uf) async {
    final UserFridge updatedUserFridge = await ApiRoutes().modifyUserFridge(userFridge: uf);
    _fridgeData.first = updatedUserFridge;

    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_fridges-$userId.json";
    final Directory dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    file.writeAsStringSync(
      jsonEncode(_fridgeData.map((e) => e.toJson()).toList()),
      flush: true,
    );

    final String mainFridgeFileName = "main_fridge-$userId.json";
    final File mainFridgeFile = File("${dir.path}/$mainFridgeFileName");
    mainFridgeFile.writeAsStringSync(
      jsonEncode(uf.toJson()),
      flush: true,
    );

    notifyListeners();
  }

  Future<List<PFCDataItem>> extractNutrition() async {
    final protein = _fridgeItemsData.fold<double>(
      0,
          (sum, element) {
        if (element.product!.nutrition != null) {
          return sum +
              element.product!.nutrition!.protein!.total! /
                  100 *
                  (element.amount!.value! > 0 ? element.amount!.value! : 0);
        }
        return sum;
      },
    );

    final fat = _fridgeItemsData.fold<double>(
      0,
          (sum, element) {
        if (element.product!.nutrition != null) {
          return sum +
              element.product!.nutrition!.fat!.total! /
                  100 *
                  (element.amount!.value! > 0 ? element.amount!.value! : 0);
        }
        return sum;
      },
    );

    final carbs = _fridgeItemsData.fold<double>(
      0,
          (sum, element) {
        if (element.product!.nutrition != null) {
          return sum +
              element.product!.nutrition!.carbs!.total! /
                  100 *
                  (element.amount!.value! > 0 ? element.amount!.value! : 0);
        }
        return sum;
      },
    );

    final nutritionData = [
      PFCDataItem(
        value: protein,
        label: "Protein",
        color: HavkaColors.protein,
        icon: FontAwesomeIcons.dna,
      ),
      PFCDataItem(
        value: fat,
        label: "Fat",
        color: HavkaColors.fat,
        icon: FontAwesomeIcons.droplet,
      ),
      PFCDataItem(
        value: carbs,
        label: "Carbs",
        color: HavkaColors.carbs,
        icon: FontAwesomeIcons.wheatAwn,
      ),
    ];
    return nutritionData;
  }

}