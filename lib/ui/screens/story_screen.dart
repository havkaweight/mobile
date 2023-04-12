import 'dart:async';

import 'package:flutter/material.dart';
import 'package:health_tracker/routes/sharp_page_route.dart';
import 'package:health_tracker/ui/screens/onboarding_screens.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/widgets/story_bars.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryPage extends StatefulWidget {
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  List<double> percentWatched = [];
  late Timer watchingTimer;
  int currentStoryIndex = 0;
  final List<Widget> stories = [
    OnboardingScreen1(),
    OnboardingScreen2(),
    OnboardingScreen3(),
  ];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < stories.length; i++) {
      percentWatched.add(0);
    }

    _startWatching(5);
  }

  @override
  void dispose() {
    watchingTimer.cancel();
    super.dispose();
  }

  Future<void> _startWatching(int seconds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    watchingTimer =
        Timer.periodic(Duration(milliseconds: seconds * 10), (Timer timer) {
      setState(() {
        if (percentWatched[currentStoryIndex] + 0.01 < 1) {
          percentWatched[currentStoryIndex] += 0.01;
        } else {
          percentWatched[currentStoryIndex] = 1;
          timer.cancel();

          if (currentStoryIndex < stories.length - 1) {
            currentStoryIndex++;
            _startWatching(5);
          } else {
            prefs.setBool("skipOnboarding", true);
            Navigator.pushAndRemoveUntil(
              context,
              SharpPageRoute(builder: (context) => SignInScreen()),
              (r) => false,
            );
          }
        }
      });
    });
  }

  double _offset = 0;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences?> snapshot) {
        final SharedPreferences? prefs = snapshot.data;
        return Transform.translate(
          offset: Offset(0.0, _offset),
          child: GestureDetector(
            onVerticalDragDown: (details) {
              setState(() {});
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                if (details.delta.dy > 0) {
                  _offset += details.delta.dy / height * 150;
                }
              });
            },
            onVerticalDragEnd: (details) {
              if (_offset > 50) {
                prefs!.setBool("skipOnboarding", true);
                Navigator.pushAndRemoveUntil(
                  context,
                  SharpPageRoute(builder: (context) => SignInScreen()),
                  (r) => false,
                );
              } else {
                _offset = 0;
              }
            },
            onTapUp: (TapUpDetails details) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double dx = details.globalPosition.dx;
              if (dx < screenWidth / 2) {
                setState(() {
                  if (currentStoryIndex > 0) {
                    percentWatched[currentStoryIndex - 1] = 0;
                    percentWatched[currentStoryIndex] = 0;
                    currentStoryIndex--;
                  } else {
                    percentWatched[currentStoryIndex] = 0;
                    currentStoryIndex = 0;
                  }
                });
              } else {
                setState(() {
                  if (currentStoryIndex < stories.length - 1) {
                    percentWatched[currentStoryIndex] = 1;
                    currentStoryIndex++;
                  } else {
                    percentWatched[currentStoryIndex] = 1;
                  }
                });
              }
            },
            child: Hero(
              tag: "get-started",
              child: Stack(
                children: [
                  stories[currentStoryIndex],
                  StoryBars(
                    percentWatched: percentWatched,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
