import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';

class RoundedButton extends StatelessWidget {
  final String? text;
  final void Function()? onPressed;
  final Color? color;
  final double width;
  final Color? textColor;
  final FocusNode? focusNode;

  const RoundedButton({
    super.key,
    this.width = 100,
    this.text,
    this.onPressed,
    this.color = HavkaColors.green,
    this.textColor = Colors.white,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: TextButton(
          focusNode: focusNode,
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5.0),
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
      ),
    );
  }
}

class RoundedIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final Color? color;
  final Color? iconColor;
  final Icon? icon;
  final FaIcon? faIcon;

  const RoundedIconButton({
    required Key key,
    this.icon,
    this.faIcon,
    this.onPressed,
    this.color = Colors.green,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: HavkaColors.green,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        child: IconButton(
          padding: const EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 15.0,
          ),
          onPressed: onPressed,
          icon: icon ?? faIcon!,
        ),
      ),
    );
  }
}
