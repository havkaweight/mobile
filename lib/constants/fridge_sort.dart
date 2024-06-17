import 'package:flutter/material.dart';
import 'package:havka/constants/colors.dart';

enum FridgeOrder { ascending, descending }
enum FridgeFilter { protein, fat, carbs }

class FridgeSort {
  FridgeFilter? filterBy;
  FridgeOrder? order;

  FridgeSort({
    this.filterBy,
    this.order = FridgeOrder.descending,
  });

  Color get color {
    switch (filterBy) {
      case FridgeFilter.protein:
        return HavkaColors.protein;
      case FridgeFilter.fat:
        return HavkaColors.fat;
      case FridgeFilter.carbs:
        return HavkaColors.carbs;
      default:
        return HavkaColors.black;
    }
  }

  String get text {
    return filterBy != null
        ? order == FridgeOrder.descending
          ? "High to Low"
          : "Low to High"
        : order == FridgeOrder.descending
          ? "New to Old"
          : "Old to New";
  }
}
