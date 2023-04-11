import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
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
      // darkTheme: themeDataDark,
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
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.dark,
    );
    return FutureBuilder(
      future: authService.isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SplashScreen();
        } else {
          if (snapshot.data!) {
            return MainScreen();
          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }
}

class GoogleSignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: GoogleSignInButton(),
      ),
    );
  }
}
