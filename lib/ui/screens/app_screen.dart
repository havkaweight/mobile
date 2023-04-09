import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/ui/widgets/button.dart';

class MainListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: const Drawer(),
      appBar: AppBar(
        backgroundColor: HavkaColors.green,
        centerTitle: true,
        title: const Text(
          'Havka',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Hi',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 36,
              ),
            ),
          ),
          // Image.asset(
          //   'assets/images/fridge.jpg',
          //   height: 400,
          //   width: 400,
          // ),
          Container(
            width: 400.0,
            height: 400.0,
            margin: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/fridge_double.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Text('Fridge') /* add child content here */,
          ),
          GoogleSignInButton(),
          Expanded(
            child: ListView.builder(
              itemCount: 40,
              itemBuilder: (BuildContext ctx, int index) {
                return Container(
                  margin: EdgeInsets.all(5),
                  child: Text(
                    'item $index',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                    ),
                  ),
                );
              },
            ),
          ),
          // ListView(
          //   children: [
          //     Text('item 120',
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(
          //         color: Colors.black,
          //         fontSize: 36,
          //       ),
          //     ),
          //     Text('item 121',
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(
          //         color: Colors.black,
          //         fontSize: 36,
          //       ),
          //     ),
          //     Text('item 122',
          //       textAlign: TextAlign.center,
          //       style: const TextStyle(
          //         color: Colors.black,
          //         fontSize: 36,
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}
