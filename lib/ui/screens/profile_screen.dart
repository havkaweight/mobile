import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/model/device_service.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/routes/sharp_page_route.dart';
import 'package:health_tracker/ui/screens/authorization.dart';
import 'package:health_tracker/ui/screens/devices_screen.dart';
import 'package:health_tracker/ui/screens/profile_edit_screen.dart';
import 'package:health_tracker/ui/screens/scrolling_behavior.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/user_consumption_screen.dart';
import 'package:health_tracker/ui/widgets/bar_chart_timeline.dart';
import 'package:health_tracker/ui/widgets/donut_chart.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/line_chart.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/protein.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/utils/utils.dart';
import 'package:intl/intl.dart';
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
                  FutureBuilder(
                    future: _apiRoutes.getMe(),
                    builder:
                        (BuildContext context, AsyncSnapshot<User> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: HavkaProgressIndicator());
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: HavkaProgressIndicator());
                      }
                      return Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg',
                                width: MediaQuery.of(context).size.width * 0.3,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Text(
                                        showUsername(snapshot.data!.username!),
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileEditingScreen(
                                                user: snapshot.data!,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          FontAwesomeIcons.userPen,
                                          color: HavkaColors.grey[100],
                                        ),
                                        iconSize: 15,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.rulerVertical,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                20,
                                                0,
                                              ),
                                              child: Text(
                                                '${snapshot.data!.bodyStats!.height!.value!.toInt()} cm',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            const FaIcon(
                                              FontAwesomeIcons.weightScale,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                0,
                                                0,
                                              ),
                                              child: Text(
                                                '${snapshot.data!.bodyStats!.weight!.value} kg',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 11.0),
                            child: Text(
                              '${DateTime.now().day}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            onPressed: _showCalendar,
                            icon: const Icon(FontAwesomeIcons.calendar),
                            iconSize: 33,
                          ),
                        ],
                      ),
                      RoundedButton(
                        text: 'Show history',
                        onPressed: _buildWeightingsHistory,
                      ),
                    ],
                  ),
                  FutureBuilder(
                    future: _apiRoutes.getUserConsumption(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<List<UserConsumptionItem>> snapshot,
                    ) {
                      if (snapshot.connectionState != ConnectionState.done ||
                          !snapshot.hasData) {
                        return SizedBox(
                          height: chartHeight,
                          child: const HavkaProgressIndicator(),
                        );
                      }
                      final List<UserConsumptionItem> userConsumption =
                          snapshot.data!;
                      final DateTime? minDate = [
                        for (UserConsumptionItem userConsumptionItem
                            in userConsumption)
                          userConsumptionItem.consumedAt ??
                              userConsumptionItem.createdAt
                      ].reduce(
                        (value, element) =>
                            value!.isBefore(element!) ? value : element,
                      );
                      final DateTime? maxDate = [
                        for (UserConsumptionItem userConsumptionItem
                            in userConsumption)
                          userConsumptionItem.consumedAt ??
                              userConsumptionItem.createdAt
                      ].reduce(
                        (value, element) =>
                            value!.isAfter(element!) ? value : element,
                      );
                      final List<DateTime> datesPeriod =
                          getDaysInBetween(minDate!, maxDate!);
                      final List<DataItem> weeklyData = [];
                      for (final DateTime date in datesPeriod) {
                        weeklyData.add(
                          DataItem(
                            userConsumption.fold(0, (previousValue, element) {
                              if ((element.consumedAt ?? element.createdAt)!
                                      .difference(date)
                                      .inDays ==
                                  0) {
                                return previousValue += element.amount!.value;
                              }
                              return previousValue;
                            }),
                            DateFormat('MMM dd').format(date),
                            Colors.amber[500]!,
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40.0,
                          vertical: 10.0,
                        ),
                        child: SizedBox(
                          height: chartHeight,
                          child: CustomPaint(
                            painter: HavkaBarChart(weeklyData),
                            child: Container(),
                          ),
                        ),
                      );
                    },
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
                      final List<PFCDataItem> nutritionData = [
                        PFCDataItem(
                          proteins,
                          "Protein",
                          HavkaColors.protein,
                          FontAwesomeIcons.dna,
                        ),
                        PFCDataItem(
                          fats,
                          "Fat",
                          HavkaColors.fat,
                          FontAwesomeIcons.droplet,
                        ),
                        PFCDataItem(
                          carbs,
                          "Carbs",
                          HavkaColors.carbs,
                          FontAwesomeIcons.wheatAwn,
                        ),
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
                                HavkaStackBarChart(
                                  data: nutritionData,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                              vertical: 40.0,
                            ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 10.0,
                    ),
                    child: SizedBox(
                      height: chartHeight,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: CustomPaint(
                        painter: HavkaLineChart(mockDataPoints),
                        child: Container(),
                      ),
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

  Future _showCalendar() async {
    return showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        final double mHeight = MediaQuery.of(context).size.height;
        return SafeArea(
          child: SizedBox(
            height: mHeight * 0.9,
            child: Column(
              children: [
                Holder(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('This widget is not ready yet.'),
                  ],
                ),
              ],
            ),
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
