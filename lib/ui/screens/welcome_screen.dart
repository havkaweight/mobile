import 'package:flutter/material.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/main_screen.dart';
import 'package:health_tracker/ui/screens/onboarding.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/story_screen.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:health_tracker/ui/widgets/button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import 'package:health_tracker/addons/google_sign_in/google_sign_in/lib/google_sign_in.dart';
// import 'package:health_tracker/api/constants.dart';
// import 'package:health_tracker/api/methods.dart';
// import 'package:health_tracker/constants/colors.dart';
// import 'package:health_tracker/ui/screens/authorization.dart';
// import 'package:health_tracker/ui/screens/main_screen.dart';
// import 'package:health_tracker/ui/screens/sign_up_screen.dart';
// import 'package:health_tracker/ui/widgets/popup.dart';
// import 'package:health_tracker/ui/widgets/progress_indicator.dart';
// import 'package:health_tracker/ui/widgets/rounded_button.dart';
// import 'package:health_tracker/ui/widgets/rounded_textfield.dart';
// import 'package:health_tracker/ui/widgets/rounded_textfield_obscure.dart';
// import 'package:health_tracker/ui/widgets/screen_header.dart';
// import 'package:http/http.dart' as http;

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Widget? body;

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
      backgroundColor: Theme.of(context).backgroundColor,
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
