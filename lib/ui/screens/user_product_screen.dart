import 'package:flutter/material.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/screen_header.dart';

class UserProductScreen extends StatefulWidget {
  final Map<String, String> prod;

  const UserProductScreen({
    Key key,
    @required this.prod
  }) : super(key: key);

  @override
  _UserProductScreenState createState() => _UserProductScreenState();
}

class _UserProductScreenState extends State<UserProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScreenHeader(text: widget.prod['name']),
            ScreenSubHeader(text: widget.prod['desc']),
            RoundedButton(
              text: 'Weigh',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleScreen(prod: widget.prod)))
            )
          ]
        )
      ),
    );
  }
}