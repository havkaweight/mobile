import 'package:flutter/material.dart';
import '/presentation/screens/auth_screen.dart';
import '/presentation/screens/story_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  Future<bool> _skipOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("skipOnboarding") ?? false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FutureBuilder(
        future: _skipOnboarding(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!) {
              return AuthScreen();
            } else {
              return StoryPage();
            }
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
