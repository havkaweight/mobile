import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:health_tracker/api/constants.dart';
import 'package:health_tracker/model/device_service.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/model/user_product_weighting.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:http/http.dart' as http;

class ApiRoutes {
  Future<bool> signUp(String email, String password) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'email': email,
      'password': password,
    };

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      // 'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.post(
        Uri.https(
          Api.host,
          '${Api.prefix}${Api.authService}${Api.signup}',
          body,
        ),
        headers: headers,
        body: body,
      );

      if (response.statusCode != HttpStatus.created) {
        throw Exception("${response.statusCode} ${response.body}");
      }

      return signIn(email, password);
    } catch (error) {
      debugPrint("Error: $error");
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    final Map<String, dynamic> body = <String, dynamic>{
      'email': email,
      'password': password,
    };

    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
      // 'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.post(
        Uri.https(
          Api.host,
          '${Api.prefix}${Api.authService}${Api.signin}',
        ),
        headers: headers,
        body: body,
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        log("Access Token: ${data['access_token'] as String}");
        await setToken(data['access_token'] as String);
        await setRefreshToken(data['refresh_token'] as String);
        return true;
      } else {
        // throw Exception("Failed sign in.");
        return false;
      }
    } catch (e) {
      debugPrint("Error $e");
      return false;
    }
  }

  Future<bool> tokenUpdate() async {
    final String? refreshToken = await getRefreshToken();
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $refreshToken',
    };

    try {
      final http.Response response = await http.get(
        Uri.https(
          Api.host,
          '${Api.prefix}${Api.authService}${Api.tokenUpdate}',
        ),
        headers: headers,
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        await setToken(data['access_token'] as String);
        await setRefreshToken(data['refresh_token'] as String);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error $e");
      return false;
    }
  }

  Future<bool> signInGoogle(String idToken) async {
    try {
      final Map<String, String> body = <String, String>{
        "id_token": idToken,
      };
      final http.Response response = await http.post(
        Uri.https(
          Api.host,
          '${Api.prefix}${Api.authService}${Api.signInGoogle}',
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        log("Access Token: ${data["access_token"] as String}");
        if (data.containsKey('access_token')) {
          setToken(data['access_token'] as String);
          return true;
        } else {
          return false;
        }
      } else {
        // throw Exception("Failed sign in.");
        return false;
      }
    } catch (error) {
      debugPrint("Error $error");
      return false;
    }
  }

  Future<User> getMe() async {
    try {
      final token = await getToken();
      final Map<String, String> headers = <String, String>{
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final http.Response response = await http.get(
        Uri.https(Api.host, '${Api.prefix}${Api.monolithService}${Api.me}'),
        headers: headers,
      );

      if (response.statusCode == HttpStatus.unauthorized) {
        throw Exception('Unauthorized');
      } else if (response.statusCode == HttpStatus.forbidden) {
        final bool isTokenRelevant = await tokenUpdate();
        if (!isTokenRelevant) {
          throw Exception("Access Denied");
        }
        return await getMe();
      }

      final user =
          User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      return user;
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  Future<List<UserProduct>> getUserProductsList() async {
    // final Dio dio = Dio();
    // final DioCacheManager dioCacheManager =
    //     DioCacheManager(CacheConfig(baseUrl: "https://${Api.host}"));
    // dio.interceptors.add(dioCacheManager.interceptor as Interceptor);
    final token = await storage.read(key: 'jwt');
    final Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    // final Response response = await dio.get(
    //   'https://${Api.host}${Api.prefix}${Api.monolithService}${Api.userProducts}',
    //   options: buildCacheOptions(const Duration(days: 7), forceRefresh: true),
    // );

    final http.Response response = await http.get(
      Uri.https(
          Api.host, '${Api.prefix}${Api.monolithService}${Api.userProducts}'),
      headers: headers,
    );

    if (response.statusCode != HttpStatus.ok) {
      return [];
    }
    final userProducts = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final List<UserProduct> userProductsList =
        userProducts.map<UserProduct>((json) {
      return UserProduct.fromJson(json as Map<String, dynamic>);
    }).toList();
    return userProductsList;
  }

  Future<String> deleteUserProduct(UserProduct userProduct) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.delete(
      Uri.https(
        Api.host,
        '${Api.prefix}${Api.monolithService}${Api.userProducts}/${userProduct.id}',
      ),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return 'success';
    }
    return 'bad';
  }

  Future<dynamic> getProductByBarcode(String? barcode) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
      Uri.https(
        Api.host,
        '${Api.prefix}${Api.monolithService}${Api.productByBarcode}/$barcode',
      ),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print(response.statusCode);
    if (response.statusCode == HttpStatus.notFound) {
      throw Exception('Not found');
    }
    if (response.statusCode != 200) {
      return;
    }
    final productJson =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final Product product = Product.fromJson(productJson);
    return product;
  }

  Future<List<Product>> getProductsBySearchingRequest(String request) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
      Uri.https(Api.host, '${Api.prefix}${Api.productsByRequest}/$request'),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == HttpStatus.notFound) {
      throw Exception('Not found');
    }
    if (response.statusCode != HttpStatus.ok) {
      return [];
    }
    final products = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final List<Product> productsList = products.map<Product>((json) {
      return Product.fromJson(json as Map<String, dynamic>);
    }).toList();
    return productsList;
  }

  Future<List<UserDevice>> getUserDevicesList() async {
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.https(
        Api.host,
        '${Api.prefix}${Api.monolithService}${Api.userDevices}',
      ),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != HttpStatus.ok) {
      return [];
    }
    final devices = jsonDecode(response.body) as List;
    final List<UserDevice> devicesList = devices.map<UserDevice>((json) {
      return UserDevice.fromJson(json as Map<String, dynamic>);
    }).toList();
    return devicesList;
  }

  Future<List<DeviceService>> getDevicesServicesList() async {
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.https(Api.host, '${Api.prefix}${Api.serviceByName}/info'),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode != 200) {
      return [];
    }
    final devicesServices = jsonDecode(response.body) as List;
    final List<DeviceService> devicesServicesList =
        devicesServices.map<DeviceService>((json) {
      return DeviceService.fromJson(json as Map<String, dynamic>);
    }).toList();
    return devicesServicesList;
  }

  Future<UserDevice?> userDeviceAdd(String serialId) async {
    debugPrint(serialId);
    final token = await getToken();
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}${Api.userDevicesAdd}'),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, String>{'serial_id': serialId}),
    );

    if (response.statusCode == 201) {
      return UserDevice.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
  }

  Future<List<Product>> getProductsList() async {
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.https(Api.host, '${Api.prefix}${Api.monolithService}${Api.products}'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != HttpStatus.ok) {
      return [];
    }
    final products = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final List<Product> productsList = products.map<Product>((json) {
      return Product.fromJson(json as Map<String, dynamic>);
    }).toList();
    return productsList;
  }

  Future addUserProduct(Product product) async {
    final token = await storage.read(key: 'jwt');
    final Map<String, String?> body = {
      "product_id": product.id,
    };
    final http.Response response = await http.post(
      Uri.https(
        Api.host,
        '${Api.prefix}${Api.monolithService}${Api.userProducts}',
        body,
      ),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      // body: jsonEncode(product.productIdToJson()),
    );

    debugPrint('${response.statusCode} ${response.body}');
  }

  Future<bool> addProduct(Product product) async {
    try {
      final token = await storage.read(key: 'jwt');
      final http.Response response = await http.post(
        Uri.https(
          Api.host,
          '${Api.prefix}${Api.monolithService}${Api.products}',
        ),
        headers: <String, String>{
          'Content-type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(product.toJson()),
      );
      debugPrint('${response.statusCode} ${response.body}');
      return true;
    } catch (error) {
      debugPrint("Error $error");
      return false;
    }
  }

  Future<List<UserProductWeighting>> getWeightingsHistory() async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.get(
      Uri.https(Api.host, '${Api.prefix}${Api.userProductsWeightingsHistory}'),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode != 200) {
      return [];
    }
    final userProductsWeightings =
        jsonDecode(utf8.decode(response.bodyBytes)) as List;
    final List<UserProductWeighting> userProductsWeightingsList =
        userProductsWeightings.map<UserProductWeighting>((json) {
      return UserProductWeighting.fromJson(json as Map<String, dynamic>);
    }).toList();
    return userProductsWeightingsList;
  }

  Future addUserProductWeighting(
    double netWeight,
    UserProduct userProduct, {
    UserDevice? userDevice,
  }) async {
    final token = await storage.read(key: 'jwt');
    final http.Response response = await http.post(
      Uri.https(Api.host, '${Api.prefix}${Api.userProductsWeightingAdd}'),
      headers: <String, String>{
        'Content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'product_id': userProduct.product!.id,
        'user_product_id': userProduct.id,
        // 'user_device_id': userDevice.id,
        'weight': netWeight
      }),
    );

    debugPrint('${response.statusCode} ${response.body}');
  }
}
