import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/domain/entities/product/nutrition.dart';
import 'package:havka/utils/format_number.dart';
import '../../domain/entities/product/product.dart';
import '/core/constants/colors.dart';
import '/core/constants/icons.dart';

class NutritionInfo extends StatelessWidget {
  final Product product;
  final double weight;

  final bool showIcons;
  final double iconSize;
  final bool showLabels;
  final TextStyle? textStyle;

  const NutritionInfo({
    Key? key,
    required this.product,
    this.weight = 100,
    this.showIcons = true,
    this.iconSize = 10,
    this.showLabels = false,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildItem(
          context: context,
          label: 'Energy',
          unit: 'g',
          value: product.nutrition!.energy!.kcal! / product.nutrition!.valuePerInBaseUnit! * weight,
          color: HavkaColors.kcal,
          icon: HavkaIcons.energy,
        ),
        _buildItem(
          context: context,
          label: 'Protein',
          unit: product.baseUnit!,
          value: product.nutrition!.protein!.total! / product.nutrition!.valuePerInBaseUnit! * weight,
          color: HavkaColors.protein,
          icon: HavkaIcons.protein,
        ),
        _buildItem(
          context: context,
          label: 'Fat',
          unit: product.baseUnit!,
          value: product.nutrition!.fat!.total! / product.nutrition!.valuePerInBaseUnit! * weight,
          color: HavkaColors.fat,
          icon: HavkaIcons.fat,
        ),
        _buildItem(
          context: context,
          label: 'Carbs',
          unit: product.baseUnit!,
          value: product.nutrition!.carbs!.total! / product.nutrition!.valuePerInBaseUnit! * weight,
          color: HavkaColors.carbs,
          icon: HavkaIcons.carbs,
        ),
      ],
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required String label,
    required String unit,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: Row(
        children: [
          if (showIcons)
            Container(
              margin: EdgeInsets.only(right: 4),
              child: Icon(icon, size: iconSize, color: color),
            ),
          if (showLabels)
            Text(
              label,
              style: textStyle?.copyWith(color: color) ?? Theme.of(context).textTheme.bodyMedium,
            ),
          Text(
            '${formatNumber(value)} $unit',
            // style: textStyle?.copyWith(color: color) ?? Theme.of(context).textTheme.bodySmall,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
