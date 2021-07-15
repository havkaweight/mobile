import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/ui/screens/child_widget.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';

import '../../main.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    super.initState();
  }

  PageController _pageController = PageController(
    initialPage: 0,
  );
  int currentIndex = 0;

  Widget childWidget = ChildWidget(
    screen: AvailableScreen.Fridge,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold (
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).backgroundColor,
          selectedItemColor: Theme.of(context).accentColor,
          unselectedItemColor: Color(0x885BBE78),
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            currentIndex = value;
            _pageController.animateToPage(
              value,
              duration: Duration(milliseconds: 200),
              curve: Curves.linear,
            );
          },
          items: [
            BottomNavigationBarItem(
                icon: currentIndex==0 ? Icon(Icons.kitchen) : Icon(Icons.kitchen_outlined),
                label: 'Fridge'
            ),
            BottomNavigationBarItem(
                icon: currentIndex==1 ? Icon(Icons.monitor_weight) : Icon(Icons.monitor_weight_outlined),
                label: 'Measure'
            ),
            BottomNavigationBarItem(
                icon: currentIndex==2 ? Icon(Icons.person) : Icon(Icons.person_outline),
                label: 'Me'
            )
          ],
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              currentIndex = page;
            });
          },
          children: <Widget>[
            ChildWidget(screen: AvailableScreen.Fridge),
            ChildWidget(screen: AvailableScreen.Scale),
            ChildWidget(screen: AvailableScreen.Profile)
          ]
        )
      );
  }
}