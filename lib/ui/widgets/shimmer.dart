import 'package:flutter/material.dart';
import 'package:health_tracker/ui/widgets/fridgeitem.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/colors.dart';


Shimmer getShimmerLoading() {
  return Shimmer.fromColors(
    baseColor: HavkaColors.bone[100]!,
    highlightColor: HavkaColors.bone[200]!,
    child: Column(
      children: List.filled(8, const EmptyFridgeItem()),
    ),
  );
}