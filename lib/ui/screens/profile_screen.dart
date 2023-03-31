import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/components/profile.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/device_service.dart';
import 'package:health_tracker/model/user_device.dart';
import 'package:health_tracker/ui/screens/scrolling_behavior.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/weightings_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

import '../../main.dart';
import '../../model/data_items.dart';
import '../../model/user.dart';
import '../widgets/bar_chart.dart';
import '../widgets/donut_chart.dart';
import '../widgets/line_chart.dart';
import '../widgets/user_device_list.dart';
import 'authorization.dart';
import 'devices_screen.dart';
import 'products_screen.dart';

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
    // WidgetsBinding.instance.addObserver(this);
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
      googleSignIn.signOut();
      googleSignIn.disconnect();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
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
      backgroundColor: Theme.of(context).backgroundColor,
      body: FutureBuilder<User>(
        future: _apiRoutes.getMe(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget? widget;
          if (!snapshot.hasData) {
            widget = const Center(child: HavkaProgressIndicator());
          } else if (snapshot.hasData) {
            widget = _buildProfileScreen(snapshot);
          }
          if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignInScreen()));
            });
          }
          return widget!;
        },
      ),
    );
  }

  Widget _buildProfileScreen(AsyncSnapshot snapshot) {
    final List<DataItem> pfcData = [
      DataItem(500, "Protein", Colors.amber[200]!),
      DataItem(100, "Fat", Colors.amber[400]!),
      DataItem(200, "Carbs", Colors.amber[600]!),
    ];
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
                ProfileHeader(
                  username: '${snapshot.data.email}',
                  height: 163,
                  weight: 67,
                  photoUrl:
                      'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg',
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
                    painter: HavkaDonutChart(pfcData),
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
      }),
    );
  }

  Future _buildWeightingsHistory() {
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
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
            child: Column(children: [
              Holder(),
              Center(
                  child: Column(
                children: [
                  WeightingsScreen(),
                ],
              ))
            ]),
          );
        });
  }

  Future<dynamic> _buildScaleSearching(BuildContext context) async {
    final List<DeviceService> servicesList =
        await _apiRoutes.getDevicesServicesList();
    return showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        context: context,
        builder: (builder) {
          final double mHeight = MediaQuery.of(context).size.height;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
            child: SizedBox(
                height: mHeight * 0.85,
                child: Column(children: [
                  Holder(),
                  Center(child: DevicesScreen(servicesList))
                ])),
          );
        });
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
      ;
      // return status;
    });
  }
}
