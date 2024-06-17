import 'package:flutter/material.dart';
import 'package:havka/ui/screens/sign_in_screen.dart';
import 'package:havka/ui/screens/story_screen.dart';
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
              return SignInScreen();
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
