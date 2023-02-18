import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/ui/screens/onboarding.dart';
import 'package:health_tracker/ui/screens/onboarding_screens.dart';
import 'package:health_tracker/ui/screens/story_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/button.dart';
import 'package:health_tracker/utils/auth.dart';
import 'package:lottie/lottie.dart';

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

  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  // example of completing login
  // https://api.flutter.dev/flutter/widgets/Navigator/pushReplacement.html
  @override
  Widget build(BuildContext context) {
    return StoryPage();
    return FutureBuilder(
      future: authService.isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          if (snapshot.data == true) {
            return MainScreen();
          } else {
            // return WelcomeScreen();
            return StoryPage();
          }
        }
      },
    );

  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
  with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
    ..addListener(() {
      if(_controller.value > 0.5) {
        _controller.value = 0.5;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
          // child: Hero(
          //   tag: "splash-animation",
          //   child: Lottie.asset(
          //       'https://assets7.lottiefiles.com/packages/lf20_6yhhrbk6.json',
          //       controller: _controller,
          //   ),
          // ),
          // child: AppIcon(image: Assets.appLogo),
      ),
    );
  }
}


class GoogleSignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: GoogleSignInButton(),
      ),
    );
  }
}
