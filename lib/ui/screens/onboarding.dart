import 'package:flutter/material.dart';
import 'package:health_tracker/constants/assets.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/app_icon.dart';
import 'package:introduction_screen/introduction_screen.dart';



class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<OnboardingScreen> {
  Widget? body;

  @override
  void initState() {
    super.initState();
  }

  Widget onboardingWidget(BuildContext context) {
    final Color background = Theme.of(context).backgroundColor;
    final introductionPagesList = [
      PageViewModel(
        title: "Title of introduction page 1 ",
        body: "Welcome to the app! This is a description of how it works.",
        image: const Center(
          child: AppIcon(image: Assets.appLogo),
        ),
      ),
      PageViewModel(
        title: "Title of introduction page 2",
        body: "Welcome to the app! This is a description of how it works.",
        image: const Center(
          child: AppIcon(image: Assets.appLogo),
        ),
      ),
      PageViewModel(
        title: "Title of introduction page 3",
        body: "Welcome to the app! This is a description of how it works.",
        image: const Center(
          child: AppIcon(image: Assets.appLogo),
        ),
      )
    ];

    return IntroductionScreen(
      pages: introductionPagesList,
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Done"),
      onDone: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      },
      globalBackgroundColor: Theme.of(context).backgroundColor,
      // baseBtnStyle: TextButton.styleFrom(
      //   backgroundColor: Colors.grey.shade200,
      // ),
      skipStyle: TextButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      doneStyle: TextButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      nextStyle: TextButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    )
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: onboardingWidget(context),
    );
  }
}
