import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

Future<String?> getRefreshToken() async {
  final String? refreshToken = await storage.read(key: 'refresh_token');
  return refreshToken;
}

Future removeToken() async {
  await storage.delete(key: 'jwt');
  await storage.delete(key: 'refresh_token');
}

// Future<bool> setScale(HavkaScale scale) async {
//   await storage.write(key: scale.serviceUUID, value: scale);
//   return storage.containsKey(key: 'jwt');
// }

// Future<String> getToken() async {
//   String token = await storage.read(key: 'jwt');
//   return token;
// }
