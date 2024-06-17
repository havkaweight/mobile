import 'package:flutter/material.dart';
import 'package:havka/constants/colors.dart';

class Holder extends StatelessWidget {

  final double? height;
  final double? width;

  const Holder({
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: SizedBox(
        height: height,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.12,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
