import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/model/product.dart';

Widget buildNutritionLine(ProductNutrition? nutritionData) {
  final List<PFCDataItem> nutritionDataList = [
    PFCDataItem(
      value: nutritionData!.protein ?? 0,
      label: "Protein",
      color: HavkaColors.protein,
      icon: FontAwesomeIcons.dna,
    ),
    PFCDataItem(
      value: nutritionData.fat ?? 0,
      label: "Fat",
      color: HavkaColors.fat,
      icon: FontAwesomeIcons.droplet,
    ),
    PFCDataItem(
      value: nutritionData.carbs ?? 0,
      label: "Carbs",
      color: HavkaColors.carbs,
      icon: FontAwesomeIcons.wheatAwn,
    ),
    PFCDataItem(
      value: nutritionData.energy?.first.value ?? 0,
      label: "Kcal",
      color: HavkaColors.kcal,
      icon: FontAwesomeIcons.utensils,
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
                  nutritionDataList[index].value.toInt().toString(),
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
