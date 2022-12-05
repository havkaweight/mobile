import 'dart:async';

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
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/weightings_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/holder.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

import '../../model/user.dart';
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
        body: Center(
          child: FutureBuilder<User>(
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
        ));
  }

  Widget _buildProfileScreen(AsyncSnapshot snapshot) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
            Widget>[
          ProfileHeader(
              username: '${snapshot.data.email}',
              height: 163,
              weight: 67,
              photoUrl:
                  'https://i.pinimg.com/originals/ff/fc/5f/fffc5f9280b03622281eba858c3f14e5.jpg',
              onPressed: () {
                setState(() {
                  removeToken();
                  final GoogleSignIn _googleSignIn = GoogleSignIn();
                  _googleSignIn.disconnect();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                });
              }),
          // UserDeviceList()
        ]));
  }
}
