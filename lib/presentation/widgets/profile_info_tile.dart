import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/domain/entities/product/nutrition.dart';
import 'package:havka/domain/entities/profile/profile.dart';
import 'package:havka/utils/format_number.dart';
import '../../domain/entities/product/product.dart';
import '/core/constants/colors.dart';
import '/core/constants/icons.dart';

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String? value;

  const ProfileInfoTile({
    Key? key,
    required this.icon,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        // color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 4),
            child: Icon(
              icon,
              color: Colors.black,
              size: 15,
            ),
          ),
          Text(value ?? '-'),
        ],
      ),
    );
  }
}
