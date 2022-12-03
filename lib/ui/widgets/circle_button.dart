import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/constants/theme.dart';

class CircleButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final Color color, textColor;

  const CircleButton({
    Key? key,
    this.text,
    this.onPressed,
    this.color = HavkaColors.green,
    this.textColor = Colors.white,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          // padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          backgroundColor: color,
        ),
        child: Text(
            text!,
            style: TextStyle(
                color: textColor,
                fontSize: Theme.of(context).textTheme.button!.fontSize,
            ),
        ),
      ),
    );
  }
}
