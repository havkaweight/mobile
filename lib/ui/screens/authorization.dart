import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

const storage = FlutterSecureStorage();

Future<bool> setToken(String accessToken) async {
  await storage.write(key: 'jwt', value: accessToken);
  return storage.containsKey(key: 'jwt');
}

Future<bool> setRefreshToken(String refreshToken) async {
  await storage.write(key: 'refresh_token', value: refreshToken);
  return storage.containsKey(key: 'refresh_token');
}

Future<String?> getToken() async {
  final String? token = await storage.read(key: 'jwt');
  return token;
}

Future<String?> getUserId(token) async {
  final parts = token!.split(".");
  final String? userId = _decodeBase64(parts[1])["user_id"];
  return userId;
}

Map<String, dynamic> _decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!"');
  }

  return jsonDecode(utf8.decode(base64Url.decode(output)));
}

Future<String?> getRefreshToken() async {
  final String? refreshToken = await storage.read(key: 'refresh_token');
  return refreshToken;
}

Future removeToken() async {
  await storage.delete(key: 'jwt');
  await storage.delete(key: 'refresh_token');
}

Future<bool> isAuthorized() async {
  return await storage.containsKey(key: "jwt") &&
      await storage.containsKey(key: "refresh_token");
}
