import 'package:flutter/material.dart';
import 'authorization.dart';
import 'main_screen.dart';
import 'sign_in_screen.dart';
import 'main.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: checkLogIn(),
      builder: (context, snapshot) {
        return !isLoggedIn
          ? SignInScreen()
          : MainScreen();
      }
    );
    // return Scaffold(
    //   backgroundColor: Theme.of(context).backgroundColor,
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         ScreenHeader(
    //           text: 'Health Tracker'
    //         ),
    //         Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             RoundedButton(
    //               text: 'Sign In',
    //               color: Color(0xFF5BBE78),
    //               onPressed: () {
    //                 Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
    //               },
    //             ),
    //             RoundedButton(
    //               text: 'Sign Up',
    //               color: Color(0xFF5BBE78),
    //               onPressed: () {
    //                 Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
    //               },
    //             )
    //           ]
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
}