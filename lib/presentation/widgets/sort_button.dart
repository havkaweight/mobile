import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/icons.dart';
import '../providers/fridge_provider.dart';

class SortButton extends StatefulWidget {

  @override
  _SortButtonState createState() => _SortButtonState();
}

class _SortButtonState extends State<SortButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      lowerBound: 0.6,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animatePress() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final fridgeProvider = Provider.of<FridgeProvider>(context, listen: false);

    final Map<ProductSortType, String> titles = {
      ProductSortType.createdAt: "Date",
      ProductSortType.protein: "Proteins",
      ProductSortType.fat: "Fats",
      ProductSortType.carbs: "Carbs",
    };

    final Map<ProductSortType, IconData> icons = {
      ProductSortType.createdAt: Icons.calendar_today,
      ProductSortType.protein: HavkaIcons.protein,
      ProductSortType.fat: HavkaIcons.fat,
      ProductSortType.carbs: HavkaIcons.carbs,
    };

    final Map<ProductSortType, Color> colors = {
      ProductSortType.createdAt: HavkaColors.grey[100]!,
      ProductSortType.protein: HavkaColors.protein,
      ProductSortType.fat: HavkaColors.fat,
      ProductSortType.carbs: HavkaColors.carbs,
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        fridgeProvider.toggleSortOrder();
        _animatePress();
      },
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 5.0,
          ),
          decoration: BoxDecoration(
            color: colors[fridgeProvider.sortType]!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(
                  fridgeProvider.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: colors[fridgeProvider.sortType],
                  size: 13,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(
                  icons[fridgeProvider.sortType],
                  size: 15,
                  color: colors[fridgeProvider.sortType],
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: Text(
                  titles[fridgeProvider.sortType]!,
                  key: ValueKey(fridgeProvider.sortType),
                  style: TextStyle(
                    color: colors[fridgeProvider.sortType],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Text(
              //   titles[fridgeProvider.sortType]!,
              //   style: TextStyle(
              //     color: colors[fridgeProvider.sortType],
              //     fontSize: 12,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
