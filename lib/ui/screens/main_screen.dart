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

  final PageController _pageController = PageController(initialPage: 1);
  int currentIndex = 1;

  Widget? childWidget = const ChildWidget(
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
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: const Color(0x885BBE78),
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            currentIndex = value;
            _pageController.jumpToPage(value);
          },
          items: [
            // BottomNavigationBarItem(
            //     icon: currentIndex==0 ? const Icon(Icons.assessment) : const Icon(Icons.assessment_outlined),
            //     label: 'Analysis'
            // ),
            BottomNavigationBarItem(
                icon: GestureDetector(
                  child: currentIndex==0 ? const Icon(Icons.kitchen) : const Icon(Icons.kitchen_outlined),
                ),
                label: 'Fridge',
            ),
            BottomNavigationBarItem(
                icon: currentIndex==1 ? const Icon(Icons.person) : const Icon(Icons.person_outline),
                label: 'Me',
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
            // ChildWidget(screen: AvailableScreen.analysis),
            ChildWidget(screen: AvailableScreen.fridge),
            ChildWidget(screen: AvailableScreen.profile),
          ],
        ),
      );
  }
}
