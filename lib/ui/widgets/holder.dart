import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class Holder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    final double mHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: mHeight * 0.03,
      child: Center(
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: mWidth * 0.1,
            height: mHeight * 0.007,
            decoration: BoxDecoration(
              color: HavkaColors.bone[100],
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            ),
          ),
        ),
      ),
    );
  }
}
