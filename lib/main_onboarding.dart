import 'package:flutter/material.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';

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
  @override
  _HavkaAppState createState() => _HavkaAppState();
}

class _HavkaAppState extends State<HavkaApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 2),
            () {
          Navigator.pushReplacement(
              context,
              // MaterialPageRoute(builder: (context) => WelcomeScreen())

              PageRouteBuilder(
                pageBuilder: (_, __, ___) => WelcomeScreen(),
                transitionDuration: Duration(seconds: 1, milliseconds: 500),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ),
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
