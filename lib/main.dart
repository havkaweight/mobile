import 'package:flutter/material.dart';

import 'constants/assets.dart';
import 'constants/theme.dart';
import 'ui/screens/sign_in_screen.dart';
import 'ui/widgets/app_icon.dart';

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
      const Duration(seconds: 5),
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
