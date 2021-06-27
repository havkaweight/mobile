import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/api.dart';
import 'main.dart';
import 'package:http/http.dart' as http;

final storage = FlutterSecureStorage();

Future<bool> setToken(String value) async {
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // return prefs.setString('token', value);
  await storage.write(key: 'jwt', value: value);
  return storage.containsKey(key: 'jwt');
}

Future<String> getToken() async {
  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // return prefs.getString('token');
  String token = await storage.read(key: 'jwt');
  return token;
}

Future<bool> checkLogIn() async {
  var token = await getToken();
  final http.Response response = await http.get(
      Uri.https(Api.host, '${Api.prefix}/users/me'),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      }
  );
  return response.statusCode != 401
      ? isLoggedIn = true
      : isLoggedIn = false;
}