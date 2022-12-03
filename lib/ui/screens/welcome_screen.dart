import 'package:flutter/material.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/onboarding.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';


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
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: AppIcon(image: Assets.appLogo),
            ),
            const SizedBox(height: 50),
            const Text(
              'Welcome to Havka!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: HavkaColors.green,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: HavkaColors.green,
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF5BBE78),
                              Color(0xFF5BBE78),
                              Color(0xFF5BBE78),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => OnboardingScreen()),
                        );
                      },
                      child: const Align(
                        child: Text('Get Started'),
                      )
                    ),
                  ],
                ),
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
