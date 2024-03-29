import 'package:flutter/material.dart';

import 'authorization.dart';
import 'main_screen.dart';

class SignInCheckScreen extends StatefulWidget {
  @override
  _SignInCheckScreenState createState() => _SignInCheckScreenState();
}

class _SignInCheckScreenState extends State<SignInCheckScreen> {
  var token = getToken().then((value) => value);

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(seconds: 7),
            () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen()
              )
          );
        }
    );
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold (
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
          child: Container(
            child: Text(
              'Congrats!\nYou are in!\n🎉{$token}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00FF00),
                fontSize: 30,
              ),
            )
          )
      )
    );
  }
}