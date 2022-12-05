import 'package:flutter/material.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:health_tracker/ui/screens/app_screen.dart';
import 'package:health_tracker/utils/auth.dart';

// https://stackoverflow.com/questions/49040779/how-to-handle-a-different-login-navigation-flow
void main() {
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  // ));
  runApp(
      MaterialApp(
          theme: themeData,
          home: HavkaApp(),
      ),
  );
}

class HavkaApp extends StatefulWidget {
  @override
  _HavkaAppState createState() => _HavkaAppState();
}

class _HavkaAppState extends State<HavkaApp> {
  AuthService authService = AuthService();
  @override
  void initState() {
    super.initState();
    // check is logged in

    // Future.delayed(
    //     const Duration(seconds: 1),
    //         () {
    //         if (isLoggedIn) {
    //           Navigator.pushReplacement(
    //             context,
    //             // MaterialPageRoute(builder: (context) => WelcomeScreen())
    //
    //             PageRouteBuilder(
    //               // pageBuilder: (_, __, ___) => WelcomeScreen(),
    //               pageBuilder: (_, __, ___) => MainListPage(),
    //               transitionDuration: Duration(seconds: 1),
    //               transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    //             ),
    //           );
    //         } else {
    //           Navigator.pushReplacement(
    //             context,
    //             // MaterialPageRoute(builder: (context) => WelcomeScreen())
    //
    //             PageRouteBuilder(
    //               pageBuilder: (_, __, ___) => WelcomeScreen(),
    //               transitionDuration: Duration(seconds: 1),
    //               transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    //             ),
    //           );
    //         }
          // Navigator.pushReplacement(
          //     context,
          //     // MaterialPageRoute(builder: (context) => WelcomeScreen())
          //
          //     PageRouteBuilder(
          //       // pageBuilder: (_, __, ___) => WelcomeScreen(),
          //       pageBuilder: (_, __, ___) => MainListPage(),
          //       transitionDuration: Duration(seconds: 1),
          //       transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
          //     ),
          // );
    //     }
    // );
  }

  // example of completing login
  // https://api.flutter.dev/flutter/widgets/Navigator/pushReplacement.html
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: authService.isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return StartScreen();
        } else {
          if (snapshot.data == true) {
            return MainScreen();
          } else {
            return WelcomeScreen();
          }
        }
      },
    );

  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: const Center(
          child: AppIcon(image: Assets.appLogo)
      ),
    );
  }
}
