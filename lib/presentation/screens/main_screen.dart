import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/presentation/screens/fridge_screen.dart';
import '/presentation/screens/profile_screen.dart';
import '/presentation/screens/stats_screen.dart';

ScrollController fridgeItemsListScrollController = ScrollController();

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScreen(this.navigationShell, {Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  Timer? pageTapTimer;
  int pageTapCounter = 0;
  final pageTapGoal = 8;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.navigationShell.currentIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _bottomNavigationBar(navigationShell) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: const Color(0x885BBE78),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => _onTap(index, navigationShell),
        items: [
          BottomNavigationBarItem(
            icon: _selectedIndex == 0
                ? const Icon(Icons.query_stats)
                : const Icon(Icons.query_stats_outlined),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 1
                ? const Icon(Icons.kitchen)
                : const Icon(Icons.kitchen_outlined),
            label: "Fridge",
          ),
          BottomNavigationBarItem(
            icon: _selectedIndex == 2
                ? const Icon(Icons.person)
                : const Icon(Icons.person_outline),
            label: "Me",
          )
        ],
      ),
    );
  }

  void _onTap(int tabIndex, navigationShell) {
    if (_selectedIndex != tabIndex) {
      navigationShell.goBranch(tabIndex, initialLocation: true);
      setState(() {
        _selectedIndex = tabIndex;
      });
    } else {
      switch (_selectedIndex) {
        case 0:
          break;
        case 1:
          fridgeItemsListScrollController.animateTo(
            fridgeItemsListScrollController.position.minScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 200),
          );
          break;
        case 2:
          pageTapCounter ++;
          if (pageTapCounter >= pageTapGoal) {
            context.push("/profile/developer");
          }
          if (pageTapTimer != null) {
            pageTapTimer!.cancel();
          }
          pageTapTimer = Timer(Duration(milliseconds: 200), () => pageTapCounter = 0);
          break;
      }
    }


    // switch (tabIndex) {
    //   case 0:
    //     context.go("/stats");
    //     break;
    //   case 1:
    //     context.go("/fridge");
    //     break;
    //   case 2:
    //     context.go("/profile");
    //     break;
    // }

    // if (tabIndex == 1 && widget.navigationShell.currentIndex == 1) {
    //   fridgeItemsListScrollController.animateTo(
    //     fridgeItemsListScrollController.position.minScrollExtent,
    //     curve: Curves.easeOut,
    //     duration: const Duration(milliseconds: 200),
    //   );
    // }
    //
    // if (tabIndex == 0 && widget.navigationShell.currentIndex == 0) {
    //   pageTapCounter ++;
    //
    //   if (pageTapCounter >= pageTapGoal) {
    //     context.push("/stats/intake");
    //   }
    //
    //   if (pageTapTimer != null) {
    //     pageTapTimer!.cancel();
    //   }
    //
    //   pageTapTimer = Timer(Duration(milliseconds: 200), () => pageTapCounter = 0);
    // }
    //
    // if (tabIndex == 2 && widget.navigationShell.currentIndex == 2) {
    //   pageTapCounter ++;
    //
    //   if (pageTapCounter >= pageTapGoal) {
    //     context.push("/profile/developer");
    //   }
    //
    //   if (pageTapTimer != null) {
    //     pageTapTimer!.cancel();
    //   }
    //
    //   pageTapTimer = Timer(Duration(milliseconds: 200), () => pageTapCounter = 0);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: _bottomNavigationBar(widget.navigationShell),
      // body: IndexedStack(
      //   index: _selectedIndex,
      //   children: [
      //     StatsScreen(),
      //     FridgeScreen(),
      //     ProfileScreen(),
      //   ],
      // ),
      body: widget.navigationShell,
    );
  }
}
