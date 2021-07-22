import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/child_widget.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    super.initState();
  }

  final PageController _pageController = PageController(
    initialPage: 0,
  );
  int currentIndex = 0;

  Widget childWidget = const ChildWidget(
    screen: AvailableScreen.fridge,
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
          unselectedItemColor: const Color(0x885BBE78),
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            currentIndex = value;
            _pageController.animateToPage(
              value,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
            );
          },
          items: [
            BottomNavigationBarItem(
                icon: currentIndex==0 ? const Icon(Icons.kitchen) : const Icon(Icons.kitchen_outlined),
                label: 'Fridge'
            ),
            BottomNavigationBarItem(
                icon: currentIndex==1 ? const Icon(Icons.monitor_weight) : const Icon(Icons.monitor_weight_outlined),
                label: 'Measure'
            ),
            BottomNavigationBarItem(
                icon: currentIndex==2 ? const Icon(Icons.person) : const Icon(Icons.person_outline),
                label: 'Me'
            )
          ],
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              currentIndex = page;
            });
          },
          children: const <Widget>[
            ChildWidget(screen: AvailableScreen.fridge),
            ChildWidget(screen: AvailableScreen.scale),
            ChildWidget(screen: AvailableScreen.profile)
          ]
        )
      );
  }
}