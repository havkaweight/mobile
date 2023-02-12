import 'package:flutter/material.dart';
import 'package:health_tracker/ui/widgets/fridgeitem.dart';
import 'package:shimmer/shimmer.dart';


Shimmer getShimmerLoading() {
  return Shimmer.fromColors(
    baseColor: Colors.green[200]!,
    highlightColor: Colors.green[50]!,
    child: Column(
      children: List.filled(8, const EmptyFridgeItem()),
    ),
  );
}