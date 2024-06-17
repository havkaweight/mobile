import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/routes/sharp_page_route.dart';
import 'package:havka/ui/screens/fridge_screen.dart';
import 'package:havka/ui/screens/intake_screen.dart';
import 'package:havka/ui/screens/profile_screen.dart';
import 'package:havka/ui/screens/stats_screen.dart';

import '../../main.dart';

ScrollController fridgeItemsListScrollController = ScrollController();

class MainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  MainScreen({
    required this.navigationShell,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PageController _controller;

  Timer? pageTapTimer;
  int pageTapCounter = 0;
  final pageTapGoal = 8;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: widget.navigationShell,
      // body: PageView(
      //   physics: const NeverScrollableScrollPhysics(),
      //   controller: _controller,
      //   children: [
      //     StatsScreen(),
      //     FridgeScreen(),
      //     ProfileScreen(),
      //   ],
      //   onPageChanged: _onPageChanged,
      // ),
    );
  }

  Widget _bottomNavigationBar() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: const Color(0x885BBE78),
        type: BottomNavigationBarType.fixed,
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            icon: widget.navigationShell.currentIndex == 0
                ? const Icon(Icons.query_stats)
                : const Icon(Icons.query_stats_outlined),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: widget.navigationShell.currentIndex == 1
                ? const Icon(Icons.kitchen)
                : const Icon(Icons.kitchen_outlined),
            label: "Fridge",
          ),
          BottomNavigationBarItem(
            icon: widget.navigationShell.currentIndex == 2
                ? const Icon(Icons.person)
                : const Icon(Icons.person_outline),
            label: "Me",
          )
        ],
      ),
    );
  }

  _onTap(int tabIndex) {
    // _controller.jumpToPage(tabIndex);
    widget.navigationShell.goBranch(tabIndex);

    if (tabIndex == 1 && widget.navigationShell.currentIndex == 1) {
      fridgeItemsListScrollController.animateTo(
        fridgeItemsListScrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      );
    }

    if (tabIndex == 0 && widget.navigationShell.currentIndex == 0) {
      pageTapCounter ++;

      if (pageTapCounter >= pageTapGoal) {
        context.push("/stats/intake");
      }

      if (pageTapTimer != null) {
        pageTapTimer!.cancel();
      }

      pageTapTimer = Timer(Duration(milliseconds: 200), () => pageTapCounter = 0);
    }

    if (tabIndex == 2 && widget.navigationShell.currentIndex == 2) {
      pageTapCounter ++;

      if (pageTapCounter >= pageTapGoal) {
        context.push("/profile/developer");
      }

      if (pageTapTimer != null) {
        pageTapTimer!.cancel();
      }

      pageTapTimer = Timer(Duration(milliseconds: 200), () => pageTapCounter = 0);
    }

  }
}
