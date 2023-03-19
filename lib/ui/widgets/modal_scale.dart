import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class ModalScale extends StatelessWidget {

  const ModalScale({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: HavkaColors.bone[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
            child: Text(
                'TEST',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    color: HavkaColors.green,
                    decoration: TextDecoration.none
                )
            )),
      ),
    );
  }
}

ModalScale showModalScale() {
  return const ModalScale();
}
