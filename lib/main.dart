import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/splash_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/button.dart';
import 'package:health_tracker/utils/auth.dart';

// https://stackoverflow.com/questions/49040779/how-to-handle-a-different-login-navigation-flow
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return FutureBuilder(
      future: authService.isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        } else {
          return WelcomeScreen();
        }
      },
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
