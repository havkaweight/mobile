import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import '/core/constants/font_family.dart';

class ScreenHeader extends StatelessWidget {
  final String text;
  const ScreenHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 5.0,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: FontFamily.roboto,
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: HavkaColors.green,
          ),
        ),
      ),
    );
  }
}

class ScreenSubHeader extends StatelessWidget {
  final String text;
  const ScreenSubHeader({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 10.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: FontFamily.roboto,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: HavkaColors.green,
        ),
      ),
    );
  }
}

class HavkaText extends StatelessWidget {
  final String text;
  const HavkaText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: HavkaColors.green,
        ),
      ),
    );
  }
}
