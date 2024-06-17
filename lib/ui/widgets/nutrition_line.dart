import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/constants/units.dart';
import 'package:havka/model/data_items.dart';
import 'package:havka/model/product.dart';
import 'package:havka/model/product_energy.dart';

import '../../constants/icons.dart';
import '../../constants/utils.dart';

Widget buildNutritionLine(ProductNutrition? nutritionData) {
  final Energy? energy = nutritionData!.energy!;
  final List<PFCDataItem> nutritionDataList = [
    PFCDataItem(
      value: (nutritionData.protein!.total ?? 0) / nutritionData.valuePerInBaseUnit! * 100.0,
      label: "Protein",
      color: HavkaColors.protein,
      icon: FontAwesomeIcons.dna,
    ),
    PFCDataItem(
      value: (nutritionData.fat!.total ?? 0) / nutritionData.valuePerInBaseUnit! * 100.0,
      label: "Fat",
      color: HavkaColors.fat,
      icon: FontAwesomeIcons.droplet,
    ),
    PFCDataItem(
      value: (nutritionData.carbs!.total ?? 0) / nutritionData.valuePerInBaseUnit! * 100.0,
      label: "Carbs",
      color: HavkaColors.carbs,
      icon: FontAwesomeIcons.wheatAwn,
    ),
    PFCDataItem(
      value: (energy?.kcal ?? 0) / nutritionData.valuePerInBaseUnit! * 100.0,
      label: energy?.kcal == null ? EnergyUnits.kj : EnergyUnits.kcal,
      color: HavkaColors.energy,
      icon: HavkaIcons.energy,
    ),
  ];
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: nutritionDataList.length,
    itemBuilder: (BuildContext context, int index) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 3.0),
                  child: Icon(
                    nutritionDataList[index].icon,
                    color: nutritionDataList[index].color,
                    size: 10,
                  ),
                ),
                Text(
                  Utils().formatNumber(nutritionDataList[index].value)!,
                  style: TextStyle(
                    color: nutritionDataList[index].color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          )
        ],
      );
    },
  );
}
