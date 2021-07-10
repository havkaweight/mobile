import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/ui/screens/child_widget.dart';
import 'package:health_tracker/ui/screens/product_measurement_screen.dart';
import 'package:health_tracker/ui/screens/sign_in_screen.dart';

import 'main.dart';

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
    screen: AvailableScreen.Profile,
  );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build (BuildContext context) {
    return /*!isLoggedIn
      ? SignInScreen()
      : */WillPopScope(
      onWillPop: () => SystemNavigator.pop(),
      child: Scaffold (
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

            setState(() {});
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Me'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.kitchen),
                label: 'Fridge'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.devices),
                label: 'Devices'
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.trending_up),
                label: 'Measure'
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
            ChildWidget(screen: AvailableScreen.Profile),
            ChildWidget(screen: AvailableScreen.Fridge),
            ChildWidget(screen: AvailableScreen.Devices),
            ChildWidget(screen: AvailableScreen.Measure)
          ]
        )
      ),
    );
  }
}