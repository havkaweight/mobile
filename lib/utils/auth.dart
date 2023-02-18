import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

const storage = FlutterSecureStorage();
// bool isLoggedIn = false;

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

// Future<String> getToken() async {
//   String token = await storage.read(key: 'jwt');
//   return token;
// }


class AuthService {
  final ApiRoutes _apiRoutes = ApiRoutes();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("skipOnboarding", true);
    try {
      await _apiRoutes.getMe();
    }
    catch (Exception) {
      return false;
    }
    return true;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    bool? futureSignIn = await _apiRoutes.signIn(email, password);
    return false;
  }

  Future<bool> signInWithGoogle() async {
    return false;
  }

  Future<bool> signUpWithEmail() async {
    return false;
  }

  Future<bool> signUpWithGoogle() async {
    return false;
  }

  Future<bool> logOut() async {
    return false;
  }

  // Future<dynamic> resetPasswordEmail(String email) async {
  //   final Map map = <String, dynamic>{};
  //   map['email'] = email;
  //   final http.Response response = await http.post(
  //       Uri.https(Api.host, '${Api.prefix}/auth/reset-password'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8'
  //       },
  //       body: map);
  //
  //   final data = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (data.containsKey('access_token') != null) {
  //       setToken(data['access_token'] as String);
  //       return Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => MainScreen()));
  //     } else {
  //       return Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => SignInScreen()));
  //     }
  //   } else {
  //     print(response.body);
  //     throw Exception('Failed sign in');
  //   }
  // }


  // Future<Future> googleSignIn(String username, String password) async {
  //   final Map<String, dynamic> queryParameters = <String, dynamic>{};
  //   queryParameters['authentication_backend'] = 'jwt';
  //   queryParameters['scopes'] = ['email', 'profile'];
  //   final http.Response response = await http.post(
  //     Uri.https(Api.host, '${Api.prefix}/auth/google', queryParameters),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8'
  //     },
  //   );
  //
  //   print(response.body);
  //   print(response.statusCode);
  //
  //   final data = jsonDecode(response.body);
  //
  //   if (response.statusCode == 200) {
  //     if (data.containsKey('access_token') != null) {
  //       setToken(data['access_token'] as String);
  //       return Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => MainScreen()));
  //     } else {
  //       return Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => SignInScreen()));
  //     }
  //   } else {
  //     print(response.body);
  //     throw Exception('Failed sign in');
  //   }
  // }
}
