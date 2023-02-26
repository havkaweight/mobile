import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/screens/onboarding_screens.dart';
import 'package:health_tracker/ui/screens/product_adding_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';
import 'package:health_tracker/ui/screens/user_products_screen.dart';
import 'package:health_tracker/ui/screens/welcome_screen.dart';
import 'package:health_tracker/ui/widgets/linear_progress_bar.dart';

import '../../main.dart';
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

    _startWatching(5);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _startWatching(int seconds) async {
    Timer.periodic(Duration(milliseconds: seconds*10), (timer) {
      setState(() {
        if(percentWatched[currentStoryIndex] + 0.01 < 1) {
          percentWatched[currentStoryIndex] += 0.01;
        }
        else {
          percentWatched[currentStoryIndex] = 1;
          timer.cancel();

          if(currentStoryIndex < stories.length - 1) {
            currentStoryIndex ++;
            _startWatching(5);
          }
          else {
            Navigator.pop(context);
          }
        }
      });
    });
  }
  double _dragDistance = 0;
  double _offset = 0;
  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Transform.translate(
      offset: Offset(0.0, _offset),
      child: GestureDetector(
        onVerticalDragDown: (details) {
          setState(() {
            _dragDistance = 0;
          });
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            if(details.delta.dy > 0) {
              _dragDistance += details.delta.dy;
              _offset += details.delta.dy / height * 150;
            }
          });
        },
        onVerticalDragEnd: (details) {
          if (_offset > 50) {
            Navigator.pop(context);
          } else {
            _offset = 0;
          }
        },
        onTapUp: (TapUpDetails details) {
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
  }
}