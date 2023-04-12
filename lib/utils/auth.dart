import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:health_tracker/api/methods.dart';

const storage = FlutterSecureStorage();

Future<bool> setToken(String value) async {
  await storage.write(key: 'jwt', value: value);
  // isLoggedIn = true;
  return storage.containsKey(key: 'jwt');
}

Future<String?> getToken() async {
  final String? token = await storage.read(key: 'jwt');
  return token;
}

Future removeToken() async {
  await storage.delete(key: 'jwt');
  // isLoggedIn = false;
}

// Future<bool> setScale(HavkaScale scale) async {
//   await storage.write(key: scale.serviceUUID, value: scale);
//   return storage.containsKey(key: 'jwt');
// }

class AuthService {
  final ApiRoutes _apiRoutes = ApiRoutes();

  // Future<bool> isLoggedIn() async {
  //   try {
  //     final HttpStatus httpStatus = await _apiRoutes.getAvailability();

  //     switch

  //   } catch (error) {
  //     debugPrint("Error: $error");
  //     return false;
  //   }
  //   return true;
  // }

  Future<bool> logOut() async {
    return false;
  }
}
