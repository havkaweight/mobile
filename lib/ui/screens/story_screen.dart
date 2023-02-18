import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/onboarding_screens.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
import 'package:health_tracker/ui/widgets/linear_progress_bar.dart';

import '../widgets/story_bars.dart';
import 'main_screen.dart';

class StoryPage extends StatefulWidget {
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  List<double> percentWatched = [];
  int currentStoryIndex = 0;
  final List<Widget> stories = [
    OnboardingScreen1(),
    OnboardingScreen2(),
    OnboardingScreen3(),
  ];

  @override
  void initState() {
    super.initState();

    for(int i = 0; i < stories.length; i++) {
      percentWatched.add(0);
    }

    _startWatching();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startWatching() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if(percentWatched[currentStoryIndex] + 0.01 < 1) {
          percentWatched[currentStoryIndex] += 0.01;
        }
        else {
          percentWatched[currentStoryIndex] = 1;
          timer.cancel();

          if(currentStoryIndex < stories.length - 1) {
            currentStoryIndex ++;
            _startWatching();
          }
          else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) {
                return SignInScreen();
              },
            ), (route) => false);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double dx = details.globalPosition.dx;
        if (dx < screenWidth / 2) {
          setState(() {
            if(currentStoryIndex > 0) {
              percentWatched[currentStoryIndex - 1] = 0;
              percentWatched[currentStoryIndex] = 0;
              currentStoryIndex --;
            }
            else {
              percentWatched[currentStoryIndex] = 0;
              currentStoryIndex = 0;
            }
          });
        }
        else {
          setState(() {
            if(currentStoryIndex < stories.length - 1) {
              percentWatched[currentStoryIndex] = 1;
              currentStoryIndex ++;
            }
            else {
              percentWatched[currentStoryIndex] = 1;
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: HavkaColors.bone[100],
        body: Stack(
          children: [
            stories[currentStoryIndex],
            StoryBars(
              percentWatched: percentWatched,
            )
          ],
        ),
      ),
    );
  }
}