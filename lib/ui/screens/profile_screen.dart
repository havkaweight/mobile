import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/model/device_service.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/routes/sharp_page_route.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/screens/devices_screen.dart';
import 'package:health_tracker/ui/screens/scrolling_behavior.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/user_consumption_screen.dart';
import 'package:health_tracker/ui/widgets/bar_chart.dart';
import 'package:health_tracker/ui/widgets/donut_chart.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/line_chart.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/stack_bar_chart.dart';

final flutterReactiveBle = FlutterReactiveBle();

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  // AppLifecycleState _notification;

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   setState(() { _notification = state; });
  //   print(_notification);
  // }

  void logout() {
    setState(() {
      removeToken();
      final googleSignIn = GoogleSignIn(scopes: ["email", "profile"]);
      googleSignIn.signOut();
      googleSignIn.disconnect();

      Navigator.pushAndRemoveUntil(
        context,
        SharpPageRoute(builder: (context) => SignInScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // flutterReactiveBle.statusStream.listen((status) {
    //   setState(() {});
    // });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _buildProfileScreen(),
    );
  }

  Future<List<UserProduct>> getUserProductsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('userProducts');
    final List userProducts = data == null ? [] : json.decode(data) as List;
    return userProducts.map<UserProduct>((json) {
      final UserProduct userProduct =
          UserProduct.fromJson(json as Map<String, dynamic>);
      return userProduct;
    }).toList();
  }

  Widget _buildProfileScreen() {
    final List<DataItem> weeklyData = [
      DataItem(100, "Monday", Colors.amber[500]!),
      DataItem(200, "Tuesday", Colors.amber[800]!),
      DataItem(120, "Wednesday", Colors.amber[900]!),
      DataItem(210, "Thursday", Colors.yellow[300]!),
      DataItem(80, "Friday", Colors.yellow[500]!),
      DataItem(240, "Saturday", Colors.amber[200]!),
      DataItem(270, "Sunday", Colors.amber[400]!),
    ];
    final List<DataPoint> mockDataPoints = [DataPoint(0, 0)];
    for (int i = 0; i < 30; i++) {
      mockDataPoints.add(
        DataPoint(
          mockDataPoints.last.dx + 5,
          mockDataPoints.last.dy + (Random().nextDouble() * 2 - 1) * 10,
        ),
      );
    }
    return ScrollConfiguration(
      behavior: CustomBehavior(),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          final chartHeight = MediaQuery.of(context).size.height * 0.3;
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  FutureBuilder<User>(
                    future: _apiRoutes.getMe(),
                    builder:
                        (BuildContext context, AsyncSnapshot<User> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: HavkaProgressIndicator());
                      }
                      return ProfileHeader(
                        username: '${snapshot.data!.email}',
                        height: 163,
                        weight: 67,
                        photoUrl:
                            'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg',
                      );
                    },
                  ),
                  RoundedButton(
                    text: 'Show history',
                    onPressed: _buildWeightingsHistory,
                  ),
                  FutureBuilder(
                    future: _apiRoutes.getUserProductsList(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<UserProduct>> snapshot,
                    ) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          !snapshot.hasData) {
                        return SizedBox(
                          height: chartHeight,
                          child: const HavkaProgressIndicator(),
                        );
                      }
                      final List<UserProduct> userProducts = snapshot.data!;
                      final double proteins = userProducts.fold<double>(
                        0.0,
                        (sum, element) {
                          if (element.product!.nutrition != null &&
                              element.product!.nutrition!.protein != null) {
                            return sum + element.product!.nutrition!.protein!;
                          }
                          return sum;
                        },
                      );
                      final double fats = userProducts.fold<double>(
                        0.0,
                        (sum, element) {
                          if (element.product!.nutrition != null &&
                              element.product!.nutrition!.fat != null) {
                            return sum + element.product!.nutrition!.fat!;
                          }
                          return sum;
                        },
                      );
                      final double carbs = userProducts.fold<double>(
                        0.0,
                        (sum, element) {
                          if (element.product!.nutrition != null &&
                              element.product!.nutrition!.carbs != null) {
                            return sum + element.product!.nutrition!.carbs!;
                          }
                          return sum;
                        },
                      );
                      final List<DataItem> nutritionData = [
                        DataItem(proteins, "Protein", Colors.amber[200]!),
                        DataItem(fats, "Fat", Colors.amber[400]!),
                        DataItem(carbs, "Carbs", Colors.amber[600]!),
                      ];
                      final int numberOfUserProducts = userProducts.length;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                              vertical: 10.0,
                            ),
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Protein   |   Fat   |   Carbs',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: CustomPaint(
                                    painter: HavkaStackBarChart(
                                      data: nutritionData,
                                    ),
                                    child: Container(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: chartHeight,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: CustomPaint(
                                painter: HavkaDonutChart(
                                  data: nutritionData,
                                  centerText: numberOfUserProducts.toString(),
                                ),
                                child: Container(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: chartHeight,
                    child: CustomPaint(
                      painter: HavkaLineChart(mockDataPoints),
                      child: Container(),
                    ),
                  ),
                  SizedBox(
                    height: chartHeight,
                    child: CustomPaint(
                      painter: HavkaBarChart(weeklyData),
                      child: Container(),
                    ),
                  ),
                  RoundedButton(
                    text: 'Log out',
                    onPressed: logout,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future _buildWeightingsHistory() {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (BuildContext builder) {
        final double mHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          height: mHeight * 0.85,
          child: Column(
            children: [
              Holder(),
              Center(
                child: Column(
                  children: [
                    UserConsumptionScreen(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> _buildScaleSearching(BuildContext context) async {
    final List<DeviceService> servicesList =
        await _apiRoutes.getDevicesServicesList();
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (builder) {
        final double mHeight = MediaQuery.of(context).size.height;
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: SizedBox(
            height: mHeight * 0.85,
            child: Column(
              children: [Holder(), Center(child: DevicesScreen(servicesList))],
            ),
          ),
        );
      },
    );
  }

  Future<void> isDeviceConnected(UserDevice userDevice) async {
    flutterReactiveBle
        .connectToDevice(id: userDevice.serialId!)
        .listen((update) {
      bool status = false;
      if (update.connectionState == DeviceConnectionState.connected) {
        status = true;
      } else {
        status = false;
      }
      // return status;
    });
  }
}
