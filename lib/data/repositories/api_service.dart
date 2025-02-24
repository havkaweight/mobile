import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import '../api/endpoints.dart';
import '../models/device/device_service.dart';
import '../../domain/entities/product/product.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/entities/consumption/user_consumption_item.dart';
import '../models/device/user_device_model.dart';
import '/data/models/user_fridge_item.dart';
import '/data/models/user_product_weighting.dart';
import '/presentation/screens/authorization.dart';
import 'package:http/http.dart' as http;

import '/data/models/fridge.dart';
import '/data/models/user_profile.dart';

class ApiRoutes {

  Future<bool> signUp(String email, String password) async {
    final Map<String, dynamic> body = <String, dynamic>{
      "email": email,
      "password": password,
    };

    final Map<String, String> headers = <String, String>{
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final http.Response response = await http.post(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signUp}",
        body,
      ),
      headers: headers,
      body: body,
    );

    if (response.statusCode != HttpStatus.created) {
      throw Exception("Failed to sign up");
    }

    return signIn(email: email, password: password);
  }


  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> body = {
      "email_or_username": email,
      "password": password,
    };

    final Map<String, String> headers = <String, String>{
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final http.Response response = await http.post(
      Uri.https(
        Endpoints.host,
        '${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signIn}',
      ),
      headers: headers,
      body: body,
    );

    if (response.statusCode != HttpStatus.ok) {
      return false;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    await setToken(data["access_token"] as String);
    await setRefreshToken(data["refresh_token"] as String);
    return true;
  }


  Future<bool> resetPassword(String email) async {
    final Map<String, String> headers = {
      "Content-Type": "application/json; charset=UTF-8"
    };

    final Map<String, dynamic> body = {
      "email": email
    };

    final http.Response response = await http.post(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}/auth/reset-password",
      ),
      headers: headers,
      body: body,
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to reset password");
    }
    if (!data.containsKey("access_token")) {
      throw Exception("Failed to reset password");
    }
    setToken(data["access_token"] as String);
    return true;
  }


  Future<bool> tokenVerify() async {
    final token = await getToken();
    final Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    };

    final http.Response response = await http.get(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}${Endpoints.userService}${Endpoints.tokenVerify}"
      ),
      headers: headers,
    );

    if(response.statusCode != HttpStatus.ok) {
      return false;
    }
    return true;
  }


  Future<bool> tokenUpdate() async {
    final String? refreshToken = await getRefreshToken();

    final Map<String, String> headers = <String, String>{
      "Content-Type": "application/json",
      "Authorization": "Bearer $refreshToken",
    };

    final http.Response response = await http.get(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}${Endpoints.userService}${Endpoints.tokenUpdate}",
      ),
      headers: headers,
    );

    if (response.statusCode != HttpStatus.ok) {
      // router.go("/login");
      throw Exception("Failed to refresh token");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    await setToken(data["access_token"] as String);
    await setRefreshToken(data["refresh_token"] as String);
    return true;
  }


  Future<bool> signInGoogle(String idToken) async {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "id_token": idToken,
    };

    final http.Response response = await http.post(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signInGoogle}",
      ),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to sign in with Google");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (!data.containsKey("access_token")) {
      return false;
    }

    await setToken(data["access_token"] as String);
    await setRefreshToken(data["refresh_token"] as String);
    return true;
  }


  Future<bool> signInApple(String email) async {
    final Map<String, String> headers = {
      "Content-Type": "application/json",
    };

    final Map<String, String> body = {
      "email": email,
    };

    final http.Response response = await http.post(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}${Endpoints.userService}${Endpoints.authService}${Endpoints.signInApple}",
      ),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to sign in with Apple");
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (!data.containsKey("access_token")) {
      return false;
    }

    await setToken(data["access_token"] as String);
    await setRefreshToken(data["refresh_token"] as String);
    return true;
  }


  Future<User> getMe() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);
      final Map<String, String> headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userId,
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.userService}",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to get user info");
    }

    return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<bool> deleteMe() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);
      final Map<String, String> headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userId,
      };

      return await http.delete(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.userService}id/",
            queryParams
        ),
        headers: headers,
      );
    });
    debugPrint("${response.statusCode} ${response.body}");
    return true;
  }


  Future<User> updateUsername(User user) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = <String, String>{
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userId,
      };

      return await http.patch(
        Uri.https(
          Endpoints.host,
          "${Endpoints.prefix}${Endpoints.userService}id/",
          queryParams
        ),
        headers: headers,
        body: jsonEncode(user.toJson()),
      );
    });

    print("${response.statusCode} ${response.body}");

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to update username");
    }
    return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<UserProfile> getUserProfile() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.profileService}",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load user profile");
    }

    return UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<UserProfile> createProfile(UserProfile userProfile) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.post(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.profileService}",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(userProfile.toJson()),
      );
    });

    print("${response.statusCode} ${response.body}");

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to create user profile");
    }

    return UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<UserProfile> updateProfile(UserProfile userProfile) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userProfile.id,
        "user_id": userId,
      };

      print(jsonEncode(userProfile.toJson()));

      return await http.patch(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.profileService}id/",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(userProfile.toJson()),
      );
    });

    print("${response.statusCode} ${response.body}");

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to update user profile");
    }

    return UserProfile.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<bool> getAvailability() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();

      final Map<String, String> headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      return await http.get(
        Uri.https(
          Endpoints.host,
          "${Endpoints.prefix}${Endpoints.userService}${Endpoints.me}",
        ),
        headers: headers,
      );
    });

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to get availability status");
    }
    return true;
  }


  Future<List<UserFridgeItem>> getUserFridgeItemsList(UserFridge userFridge) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
        "fridge_id": userFridge.fridgeId
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeItem}",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load Fridge Items");
    }

    final UserFridgeItems = jsonDecode(utf8.decode(response.bodyBytes)) as Iterable;
    return UserFridgeItems.map<UserFridgeItem>((json) => UserFridgeItem.fromJson(json as Map<String, dynamic>)).toList();
  }


  Future<bool> deleteFridgeItem(UserFridgeItem userFridgeItem) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> queryParams = {
        "id": userFridgeItem.id,
        "user_id": userId,
      };

      return await http.delete(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeItem}id/",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to delete Fridge Item");
    }
    return true;
  }

  Future<List<UserConsumptionItem>> getUserConsumption() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
        "limit": "100",
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.consumptionService}${Endpoints.consumptionUser}",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load Consumption");
    }

    final userConsumption = jsonDecode(utf8.decode(response.bodyBytes)) as Iterable;
    return userConsumption.map<UserConsumptionItem>((json) => UserConsumptionItem.fromJson(json as Map<String, dynamic>)).toList();
  }


  Future<List<UserConsumptionItem>> getUserConsumptionByProduct(
      Product product) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = <String, String>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "product_id": product.id,
        "user_id": userId,
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.consumptionService}${Endpoints.consumptionUser}",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load Consumption");
    }

    final userConsumption = jsonDecode(response.body) as Iterable;
    return userConsumption.map<UserConsumptionItem>((json) => UserConsumptionItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<bool> deleteUserConsumption(UserConsumptionItem uci) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = <String, String>{
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": uci.id,
        "user_id": userId,
      };

      return await http.delete(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.consumptionService}${Endpoints.consumptionUser}id/",
            queryParams
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to delete Consumption Item");
    }
    return true;
  }

  Future<List<UserDevice>> getUserDevicesList() async {
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.https(
        Endpoints.host,
        "${Endpoints.prefix}${Endpoints.monolithService}${Endpoints.userDevices}",
      ),
      headers: <String, String>{
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load your devices");
    }

    final devices = jsonDecode(response.body) as Iterable;
    return devices.map<UserDevice>((json) => UserDevice.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<DeviceService>> getDevicesServicesList() async {
    final token = await getToken();
    final http.Response response = await http.get(
      Uri.https(
          Endpoints.host,
          "${Endpoints.prefix}${Endpoints.serviceByName}/info"
      ),
      headers: <String, String>{
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
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

  Future<UserDevice> userDeviceAdd(String serialId) async {
    debugPrint(serialId);
    final token = await getToken();
    final http.Response response = await http.post(
      Uri.https(
          Endpoints.host,
          "${Endpoints.prefix}${Endpoints.userDevicesAdd}"
      ),
      headers: <String, String>{
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(<String, String>{"serial_id": serialId}),
    );

    if (response.statusCode != HttpStatus.created) {
      throw Exception("Failed to add new device");
    }

    return UserDevice.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<http.Response> authorizedRequest(Future<http.Response> Function() requestedFunction) async {
    final bool isTokenVerified  = await tokenVerify();
    if(!isTokenVerified) {
      await tokenUpdate();
    }
    return await requestedFunction();
  }

  Future<List<Product>> getProductsList() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();

      final Map<String, String> headers = {
        "Content-Type": "application/json;charset=UTF-8",
        "Authorization": "Bearer $token",
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.productService}"
        ),
        headers: headers,
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load products");
    }

    final products = jsonDecode(utf8.decode(response.bodyBytes)) as Iterable;
    return products.map<Product>((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Fridge> createFridge() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=utf-8",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.post(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}",
            queryParams
        ),
        headers: headers,
      );
    });

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to create new Fridge");
    }

    return Fridge.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<UserFridge> createUserFridge({required UserFridge userFridge}) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=utf-8",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.post(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeUser}",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(userFridge.toJson()),
      );
    });

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to create new Fridge");
    }

    return UserFridge.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<UserFridge> modifyUserFridge({required UserFridge userFridge}) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=utf-8",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userFridge.id,
        "user_id": userId,
      };

      print(userFridge);
      Map<String, dynamic> userFridgeInfo = userFridge.toJson();

      return await http.patch(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeUser}id/",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(userFridgeInfo),
      );
    });

    print(response.body);

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to modify the Fridge");
    }

    return UserFridge.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }


  Future<bool> deleteUserFridge({required UserFridge userFridge}) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userFridge.id,
        "user_id": userId,
        "fridge_id": userFridge.fridgeId,
      };

      return await http.delete(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeUser}id/",
            queryParams
        ),
        headers: headers,
      );
    });

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to delete the Fridge");
    }

    return true;
  }


  Future<bool> deleteFridge({required UserFridge userFridge}) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "id": userFridge.fridgeId,
        "user_id": userId,
      };

      return await http.delete(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}id/",
            queryParams
        ),
        headers: headers,
      );
    });

    print("${response.statusCode} ${response.body}");

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to delete the Fridge");
    }

    return true;
  }


  Future<List<UserFridge>> getUserFridges() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=utf-8",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeUser}",
            queryParams
        ),
        headers: headers,
      );
    });

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load your Fridges");
    }

    final userFridges = jsonDecode(utf8.decode(response.bodyBytes)) as Iterable;
    return userFridges.map<UserFridge>((json) => UserFridge.fromJson(json)).toList();
  }


  Future<UserFridgeItem> addFridgeItem(UserFridge userFridge, Product product) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=utf-8",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      final Map<String, dynamic> body = {
        "fridge_id": userFridge.fridgeId,
        "product_id": product.id,
        "initial_amount": {
          "unit": product.package!.unit,
          "value": product.package!.value,
        },
        "amount": {
          "unit": product.package!.unit,
          "value": product.package!.value,
        },
      };

      return await http.post(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.fridgeService}${Endpoints.fridgeItem}",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(body),
      );
    });
    print("${response.statusCode} ${response.body}");
    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to add new Fridge Item");
    }

    return UserFridgeItem.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<Product> addProduct(Product product) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=UTF-8",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.post(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.productService}",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(product.toJson()),
      );
    });

    debugPrint("${response.statusCode} ${response.body}");

    if(response.statusCode != HttpStatus.created) {
      throw Exception("Failed to add new Product");
    }

    return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<Product> updateProduct(Product product) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-Type": "application/json;charset=UTF-8",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> queryParams = {
        "id": product.id,
        "user_id": userId,
      };

      return await http.patch(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.productService}${product.id}/",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(product.toJson()),
      );
    });

    if(response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to update the Product");
    }

    return Product.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<List<UserProductWeighting>> getWeightingsHistory() async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      return await http.get(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.userProductsWeightingsHistory}"
        ),
        headers: <String, String>{
          "Content-type": "application/json",
          "Authorization": "Bearer $token"
        },
      );
    });

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to load weighting history");
    }

    final userProductsWeightings = jsonDecode(utf8.decode(response.bodyBytes)) as Iterable;
    return userProductsWeightings.map<UserProductWeighting>((json) => UserProductWeighting.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<UserConsumptionItem> addUserConsumptionItem({
    required UserConsumptionItem userConsumptionItem,
    UserDevice? userDevice,
  }) async {
    http.Response response = await authorizedRequest(() async {
      final token = await getToken();
      final String? userId = await getUserId(token);

      final Map<String, String> headers = {
        "Content-type": "application/json;charset=utf-8",
        "Authorization": "Bearer $token",
      };

      final Map<String, dynamic> queryParams = {
        "user_id": userId,
      };

      return await http.post(
        Uri.https(
            Endpoints.host,
            "${Endpoints.prefix}${Endpoints.consumptionService}${Endpoints.consumptionUser}",
            queryParams
        ),
        headers: headers,
        body: jsonEncode(userConsumptionItem.toJson()),
      );
    });

    debugPrint("${response.statusCode} ${response.body}");

    if (response.statusCode != HttpStatus.ok) {
      throw Exception("Failed to add new Consumption");
    }

    final Map<String, dynamic> newUserConsumptionItem = jsonDecode(utf8.decode(response.bodyBytes));
    return UserConsumptionItem.fromJson(newUserConsumptionItem);
  }
}
