import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/model/user_profile.dart';
import 'package:health/health.dart';
import 'package:path_provider/path_provider.dart';
import '../model/user.dart';
import '../ui/screens/authorization.dart';
import 'data_items.dart';

class ProfileDataModel extends ChangeNotifier {
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  ProfileDataModel() {
    initData();
  }

  void initData() async {
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_profile-$userId.json";
    final Directory dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync());
      _userProfile = UserProfile.fromJson(jsonData);
      notifyListeners();
    }

    _userProfile = await ApiRoutes().getUserProfile();

    file.writeAsStringSync(
      jsonEncode(_userProfile!.toJson()),
      flush: true,
    );
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_profile-$userId.json";
    final dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    _userProfile = updatedProfile;
    if (file.existsSync()) {
      file.writeAsStringSync(
        jsonEncode(_userProfile?.toJson()),
        flush: true,
      );
    }
    notifyListeners();
  }
}