import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health_tracker/preferences/preferences.dart';
import 'package:health_tracker/utils/routes.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_tracker/constants/assets.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Center(child: AppIcon(image: Assets.appLogo)),
    );
  }

  startTimer() {
    var _duration = Duration(milliseconds: 2000);
    return Timer(_duration, navigate);
  }

  navigate() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.getBool(Preferences.isLoggedIn) ?? false) {
      Navigator.of(context).pushReplacementNamed(Routes.profile);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.signin);
    }
  }
}