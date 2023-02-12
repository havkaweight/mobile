import 'package:flutter/material.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/onboarding.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:health_tracker/ui/widgets/button.dart';
import 'package:lottie/lottie.dart';


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

  @override
  void initState() {
    super.initState();
  }

  Widget welcomeWidget(BuildContext context) {
    const double horizontalPadding = 24;
    const double verticalPadding = 36;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Hero(
                tag: "splash-animation",
                child: Lottie.network('https://assets7.lottiefiles.com/packages/lf20_6yhhrbk6.json'),
              ),
            ),
            const SizedBox(height: verticalPadding),
            const Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Text(
                'Welcome to Havka!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: HavkaColors.green,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // const SizedBox(height: verticalPadding),
            Padding(
              padding: const EdgeInsets.all(horizontalPadding),
              child: HavkaButton(
                fontSize: 20,
                child: const Align(child: Text('Get Started')),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OnboardingScreen()),
                  );
                  },
              ),
            ),
            const SizedBox(height: verticalPadding),
            Padding(
              padding: const EdgeInsets.all(horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                      'Already have an account?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: HavkaColors.green,
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  HavkaButton(
                    child: const Align(child: Text('Log In')),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInScreen()),
                      );
                    },
                  )
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: welcomeWidget(context),
    );
  }

}
