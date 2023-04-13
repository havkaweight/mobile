import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/constants/theme.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/ui/screens/splash_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/button.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';

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
  final ApiRoutes _apiRoutes = ApiRoutes();

  @override
  void initState() {
    super.initState();
  }

  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      Theme.of(context).colorScheme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.dark,
    );
    return FutureBuilder(
      future: _apiRoutes.getAvailability(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return SplashScreen();
        } else {
          final int httpStatus = snapshot.data!;
          switch (httpStatus) {
            case HttpStatus.ok:
              return MainScreen();
            case HttpStatus.badGateway:
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Theme.of(context).colorScheme.background,
                body: SafeArea(
                  child: Align(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                            Icons.sick_outlined,
                            color: Color.fromARGB(255, 112, 112, 112),
                            size: 80,
                          ),
                        ),
                        const Text("Sorry, we are temporary unavailable"),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: RoundedButton(
                            text: 'Reload',
                            onPressed: () => setState(() {}),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            default:
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
