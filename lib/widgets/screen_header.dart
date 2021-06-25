import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/font_family.dart';

class ScreenHeader extends StatelessWidget {
  final String text;
  const ScreenHeader({
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Itim',
              fontSize: 50,
              color: Color(0xFF5BBE78),
            )
        )
    );
  }
}

class ScreenSubHeader extends StatelessWidget {
  final String text;
  const ScreenSubHeader({
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Text(
            text,
            style: TextStyle(
              fontFamily: FontFamily.itim,
              fontSize: 30,
              color: Color(0xFF5BBE78),
            )
        )
    );
  }
}

class CustomText extends StatelessWidget {
  final String text;
  const CustomText({
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).accentColor
          )
        ),
    );
  }
}