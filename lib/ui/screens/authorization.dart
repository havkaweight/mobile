import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../main.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

Future<bool> setToken(String value) async {
  await storage.write(key: 'jwt', value: value);
  return storage.containsKey(key: 'jwt');
}

Future<String> getToken() async {
  String token = await storage.read(key: 'jwt');
  return token;
}

void removeToken() async {
  await storage.delete(key: 'jwt');
}