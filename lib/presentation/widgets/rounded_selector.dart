import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/constants/colors.dart';

class RoundedSelector extends StatefulWidget {
  final List<String> items;
  final String? initialItem;
  final Color fillColor;
  final Widget? descriptionText;
  final Function(String) onSelectedItem;

  RoundedSelector({
    super.key,
    required this.items,
    this.initialItem,
    this.fillColor = const Color(0x0D000000),
    this.descriptionText,
    required this.onSelectedItem,
  });

  @override
  RoundedSelectorState createState() => RoundedSelectorState();
}

class RoundedSelectorState<T extends RoundedSelector>
    extends State<RoundedSelector> with SingleTickerProviderStateMixin {

  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialItem == null ? -1 : widget.items.indexOf(widget.items.firstWhere((element) => element == widget.initialItem));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            height: 40,
            margin: EdgeInsets.only(
              top: 10.0,
              bottom: widget.descriptionText == null ? 10.0 : 0.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.items.length, (index) {
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        widget.onSelectedItem(widget.items[index]);
                      });
                    },
                    child: Container(
                      alignment: AlignmentDirectional.center,
                      margin: EdgeInsets.only(
                        right: index == widget.items.length-1 ? 0.0 : 10.0,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      decoration: BoxDecoration(
                        color: selectedIndex == index
                            ? Color(0x26000000)
                            : widget.fillColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        widget.items[index],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          widget.descriptionText == null
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(
                      top: 5.0,
                      left: 10.0,
                      right: 10.0,
                      bottom: widget.descriptionText == null ? 0.0 : 10.0),
                  alignment: AlignmentDirectional.topStart,
                  child: widget.descriptionText!,
                ),
        ],
      ),
    );
  }
}
