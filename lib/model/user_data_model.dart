import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:havka/api/methods.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import '../model/user.dart';
import '../ui/screens/authorization.dart';

class UserDataModel extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  UserDataModel() {
    initData();
  }

  void set user(otherUser) {
    if(_user != otherUser) {
      _user = otherUser;
    }
    notifyListeners();
  }

  void initData() async {
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user-$userId.json";
    final Directory dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync());
      _user = User.fromJson(jsonData);
      notifyListeners();
    }

    _user = await ApiRoutes().getMe();

    file.writeAsStringSync(
      jsonEncode(_user!.toJson()),
      flush: true,
    );
    notifyListeners();
  }

  Future<void> updateData(User updatedUser) async {
    _user = updatedUser;
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user-$userId.json";
    final dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      file.writeAsStringSync(
        jsonEncode(updatedUser.toJson()),
        flush: true,
      );
    }
    notifyListeners();
  }
}