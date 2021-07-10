import 'package:flutter/material.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/ui/screens/home.dart';
import 'package:health_tracker/routes/horizontal_route.dart';

bool isLoggedIn = false;
double weight = 3.0;
bool isWeight = false;

void main() {
  runApp(
    MaterialApp(
      theme: themeData,
      home: HavkaApp()
    )
  );
}

class HavkaApp extends StatefulWidget {
  _HavkaAppState createState() => _HavkaAppState();
}

class _HavkaAppState extends State<HavkaApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 5),
        () {
          Navigator.push(
            context,
            HorizontalRoute(HomeScreen())
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: AppIcon(image: Assets.appLogo)
      )
    );
  }
}