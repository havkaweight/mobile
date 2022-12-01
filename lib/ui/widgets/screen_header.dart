import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/font_family.dart';

class ScreenHeader extends StatelessWidget {
  final String text;
  const ScreenHeader({
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        child: Text(
            text,
            style: TextStyle(
              fontFamily: FontFamily.roboto,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: HavkaColors.green,
            ),
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Text(
            text,
            style: TextStyle(
              fontFamily: FontFamily.roboto,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: HavkaColors.green,
            )
        )
    );
  }
}

class HavkaText extends StatelessWidget {
  final String text;
  const HavkaText({
    this.text
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: HavkaColors.green
          )
        ),
    );
  }
}
