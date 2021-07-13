import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiRoutes {

  isAuthorized(response) {
    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    }
  }

  Future signIn(email, password) async {
    var pwdBytes = utf8.encode(password);
    var pwdHashed = sha256.convert(pwdBytes);
    Map map = Map<String, dynamic>();
    map['username'] = email;
    map['password'] = password;
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}${Api.login}'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: map
    );
    dynamic data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token']);
        // return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      }
      // else {
        // return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      // }
    } else {
      throw Exception('Failed sign in');
    }
  }

  Future<User> getMe() async {
    final token = await getToken();
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.me}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    isAuthorized(response);
    final user = User.fromJson(jsonDecode(response.body));
    print(response.body);
    return user;
  }

  Future<List<Product>> getUserProductsList() async {
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.https(Api.host, '${Api.prefix}${Api.product}'),
      headers: <String, String>{
        'Content-type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );
    final products = jsonDecode(utf8.decode(response.bodyBytes));
    List<Product> productsList = products.map<Product>((json) {
      return Product.fromJson(json);
    }).toList();
    return productsList;
  }

  Future _addProduct(product) async {
    print('Ya tut');
    print(jsonEncode(product.toJson()));
    final token = await storage.read(key: 'jwt');
    final http.Response _ = await http.post(
        Uri.https(Api.host, '${Api.prefix}/product/add/'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(product.toJson())
    );
    // Navigator.push(context, MaterialPageRoute(builder: (context) => UserProductsScreen()));
  }
}