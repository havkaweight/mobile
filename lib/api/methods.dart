import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/model/user_product_weighting.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

class ApiRoutes {

  void isAuthorized(http.Response response) {
    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    }
  }

  Future<bool> signIn(String email, String password) async {
    final pwdBytes = utf8.encode(password);
    var pwdHashed = sha256.convert(pwdBytes);
    final Map map = <String, dynamic>{};
    map['username'] = email;
    map['password'] = password;
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}${Api.login}'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: map
    );
    final data = jsonDecode(response.body);
    print(data);
    if (response.statusCode == 200) {
      if (data.containsKey('access_token') != null) {
        setToken(data['access_token'] as String);
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
    final queryParameters = {
      'authentication_backend': 'jwt'
    };
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.googleAuthorize}', queryParameters),
        headers: <String, String>{
          // 'Content-Type': 'application/json'
        },
    );

    final dynamic data = jsonDecode(response.body);
    print('data ${response.body}');
    print('statusCode ${response.statusCode}');
    if (response.statusCode == 200) {
      if (data.containsKey('authorization_url') != null) {
        final uri = Uri.parse(data['authorization_url'] as String);
        return uri.queryParameters['state'];
      }
    }
  }

  Future<bool> googleCallback(String serverAuthCode) async {
    final state = await googleAuthorize();
    final queryParameters = {
      'code': serverAuthCode,
      'state': state
    };
    print('state $state');
    final Map map = <String, dynamic>{};
    map['code'] = serverAuthCode;
    map['state'] = state;
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.googleCallback}', queryParameters),
        headers: <String, String>{
          // 'Content-Type': 'application/json'
        }
        );
    final dynamic data = jsonDecode(response.body);
    print(data);
    if (response.statusCode == 200) {
      if (data.containsKey('access_token') != null) {
        setToken(data['access_token'] as String);
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
    final user = User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    return user;
  }

  Future<List<UserProduct>> getUserProductsList() async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.userProducts}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(response.statusCode == 200) {
      final products = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final List<UserProduct> productsList = products.map<UserProduct>((json) {
        return UserProduct.fromJson(json as Map<String, dynamic>);
      }).toList();
      return productsList;
    }
    return [];
  }

  Future<String> deleteUserProduct(UserProduct userProduct) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.delete(
        Uri.https(Api.host, '${Api.prefix}${Api.userProductsDelete}/${userProduct.id}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(response.statusCode == 200) {
      return 'success';
    } else {
      return 'bad';
    }
  }

  Future<dynamic> getProductByBarcode(String barcode) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.productByBarcode}/$barcode'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    print(response.statusCode);
    if(response.statusCode == 200) {
      final productJson = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final Product product = Product.fromJson(productJson);
      return product;
    }
    if (response.statusCode == 404) {
      throw Exception('Not found');
    }
  }

  Future<dynamic> getProductsBySearchingRequest(String request) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.productsByRequest}/$request'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );

    if(response.statusCode == 200) {
      final products = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final List<Product> productsList = products.map<Product>((json) {
        return Product.fromJson(json as Map<String, dynamic>);
      }).toList();

      return productsList;
    }
    if (response.statusCode == 404) {
      throw Exception('Not found');
    }
  }

  Future<List<UserDevice>> getUserDevicesList() async {
    final token = await getToken();
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.userDevices}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if (response.statusCode == 200) {
      final devices = jsonDecode(response.body) as List;
      final List<UserDevice> devicesList = devices.map<UserDevice>((json) {
        return UserDevice.fromJson(json as Map<String, dynamic>);
      }).toList();
      return devicesList;
    }
    return [];
  }

  Future<UserDevice> userDeviceAdd(UserDevice userDevice) async {
    print(jsonEncode(userDevice.toJson()));
    final token = await getToken();
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}${Api.userDevicesAdd}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(userDevice.createdDataToJson())
    );

    if (response.statusCode == 201) {
      return UserDevice.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
  }

  Future<List<Product>> getProductsList() async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.products}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    if(response.statusCode == 200) {
      final products = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final List<Product> productsList = products.map<Product>((json) {
        return Product.fromJson(json as Map<String, dynamic>);
      }).toList();
      return productsList;
    }
    return [];
  }

  Future addProduct(Product product) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}${Api.userProductsAdd}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(product.productIdToJson())
    );

    print('${response.statusCode} ${response.body}');
  }

  Future<List<UserProductWeighting>> getWeightingsHistory() async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.userProductsWeightingsHistory}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        }
    );
    // print(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200) {
      final userProductsWeightings = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      final List<UserProductWeighting> userProductsWeightingsList = userProductsWeightings.map<UserProductWeighting>((json) {
        return UserProductWeighting.fromJson(json as Map<String, dynamic>);
      }).toList();
      return userProductsWeightingsList;
    }
    return [];
  }

  Future addUserProductWeighting(UserProduct userProduct, UserDevice userDevice, double netWeight) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.post(
        Uri.https(Api.host, '${Api.prefix}${Api.userProductsWeightingAdd}'),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'user_product_id': userProduct.id,
          'user_device_id': 1,
          // 'user_device_id': userDevice.id,
          'weight': netWeight
        })
    );

    print('${response.statusCode} ${response.body}');
  }

}