import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:health_tracker/model/device.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
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

  Future<bool> signIn(email, password) async {
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
    print(data);
    if (response.statusCode == 200) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token']);
        return true;
        // return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      }
      else {
        // return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      return false;
      // throw Exception('Failed sign in');
    }
  }

  Future<String> googleAuthorize() async {
    var queryParameters = {
      'authentication_backend': 'jwt'
    };
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.googleAuthorize}', queryParameters),
        headers: <String, String>{
          // 'Content-Type': 'application/json'
        },
    );

    dynamic data = jsonDecode(response.body);
    print('data ${response.body}');
    print('statusCode ${response.statusCode}');
    if (response.statusCode == 200) {
      if (data.containsKey('authorization_url')) {
        var uri = Uri.parse(data['authorization_url']);
        return uri.queryParameters['state'];
      }
    }
  }

  Future<bool> googleCallback(serverAuthCode) async {
    var state = await googleAuthorize();
    var queryParameters = {
      'code': '$serverAuthCode',
      'state': '$state'
    };
    print('state $state');
    Map map = Map<String, dynamic>();
    map['code'] = serverAuthCode;
    map['state'] = state;
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.googleCallback}', queryParameters),
        headers: <String, String>{
          // 'Content-Type': 'application/json'
        }
        );
    dynamic data = jsonDecode(response.body);
    print(data);
    if (response.statusCode == 200) {
      if (data.containsKey('access_token')) {
        setToken(data['access_token']);
        return true;
        // return Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      }
      else {
        // return Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
      }
    } else {
      return false;
      // throw Exception('Failed sign in');
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

  Future<List<UserProduct>> getUserProductsList() async {
    final token = await storage.read(key: 'jwt');
    // print('Before: $token');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.userProducts}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(response.statusCode == 200) {
      final products = jsonDecode(utf8.decode(response.bodyBytes));
      List<UserProduct> productsList = products.map<UserProduct>((json) {
        return UserProduct.fromJson(json);
      }).toList();
      // print(productsList);
      return productsList;
    }
    return [];
  }

  Future scanBarcode() async {
    await FlutterBarcodeScanner.scanBarcode(
        '#5BBE78',
        'Cancel',
        true,
        ScanMode.BARCODE
    ).then((value) => getProductByBarcode(value));
  }

  Future<dynamic> getProductByBarcode(barcode) async {
    print('getProductByBarcode');
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}/users/me/products/get?barcode=$barcode'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(response.statusCode == 200) {
      var productJson = jsonDecode(response.body);
      Product product = Product.fromJson(productJson);
      return product;
    } else {
      return 'Not found';
    }
  }

  Future<List<UserDevice>> getUserDevicesList() async {
    final token = await getToken();
    print(token);
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.userDevices}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if (response.statusCode == 200) {
      final devices = jsonDecode(response.body);
      print(devices);
      List<UserDevice> devicesList = devices.map<UserDevice>((json) {
        return UserDevice.fromJson(json);
      }).toList();
      print(devicesList);
      return devicesList;
    }
  }

  Future<UserDevice> userDeviceAdd(UserDeviceCreate userDeviceCreate) async {
    print(jsonEncode(userDeviceCreate.toJson()));
    final token = await getToken();
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}${Api.userDevicesAdd}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(userDeviceCreate.toJson())
    );

    if (response.statusCode == 201) {
      return UserDevice.fromJson(jsonDecode(response.body));
    }
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