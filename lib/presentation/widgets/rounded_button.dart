import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/core/constants/colors.dart';
import 'charts/circular_progress_bar.dart';
import '/presentation/widgets/progress_indicator.dart';

class RoundedButton extends StatefulWidget {
  final String text;
  final void Function()? onPressed;
  final Color? color;
  final double width;
  final Color? textColor;
  final FocusNode? focusNode;
  final bool isProcessed;

  RoundedButton({
    super.key,
    this.width = 100,
    required this.text,
    this.onPressed,
    this.color = HavkaColors.green,
    this.textColor = Colors.white,
    this.focusNode,
    this.isProcessed = false,
  });

  @override
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextButton(
        focusNode: widget.focusNode,
        onPressed: widget.onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          backgroundColor: widget.color,
        ),
        child: widget.isProcessed
          ? HavkaProgressIndicator()
          : Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontSize: Theme.of(context).textTheme.displaySmall!.fontSize,
              ),
            ),
      ),
    );
  }
}