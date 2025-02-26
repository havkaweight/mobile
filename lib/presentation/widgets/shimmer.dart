import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import '/presentation/widgets/fridge_item_row.dart';
import 'package:shimmer/shimmer.dart';

Shimmer getShimmerLoading() {
  return Shimmer.fromColors(
    baseColor: HavkaColors.bone[100]!,
    highlightColor: HavkaColors.bone[200]!,
    child: ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Colors.black, Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
      },
      child: Column(
        children: List.filled(6, const EmptyFridgeItem()),
      ),
    ),
  );
}
