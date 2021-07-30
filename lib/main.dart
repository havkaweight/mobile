import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:health_tracker/constants/assets.dart';

void main() {
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  // ));
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SignInScreen())
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: const Center(
        child: AppIcon(image: Assets.appLogo)
      )
    );
  }
}