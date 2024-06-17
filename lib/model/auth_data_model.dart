import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:havka/api/methods.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import '../model/user.dart';
import '../ui/screens/authorization.dart';
import 'data_items.dart';

class AuthDataModel extends ChangeNotifier {
  bool? _isAuthorized = null;
  bool? get isAuthorized => _isAuthorized;

  AuthDataModel() {
    initData();
  }

  void initData() async {
    final token = await getToken();
    _isAuthorized = token != null;
    notifyListeners();
  }
}