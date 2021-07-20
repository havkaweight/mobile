import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<bool> setToken(String value) async {
  await storage.write(key: 'jwt', value: value);
  return storage.containsKey(key: 'jwt');
}

Future<String> getToken() async {
  final String token = await storage.read(key: 'jwt');
  return token;
}

Future removeToken() async {
  await storage.delete(key: 'jwt');
}

// Future<bool> setScale(HavkaScale scale) async {
//   await storage.write(key: scale.serviceUUID, value: scale);
//   return storage.containsKey(key: 'jwt');
// }

// Future<String> getToken() async {
//   String token = await storage.read(key: 'jwt');
//   return token;
// }
