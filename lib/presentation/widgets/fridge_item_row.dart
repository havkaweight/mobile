import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/product/fridge_item.dart';
import '../../utils/format_number.dart';
import '/core/constants/colors.dart';
import 'charts/circular_progress_bar.dart';
import '/presentation/widgets/nutrition_info.dart';
import '/core/constants/icons.dart';

class FridgeItemRow extends StatefulWidget {
  final FridgeItem fridgeItem;
  final Function()? onContextMenuDuplicate;
  final Function()? onContextMenuEatWhole;
  final Function()? onContextMenuDelete;

  const FridgeItemRow({
    super.key,
    required this.fridgeItem,
    this.onContextMenuDuplicate,
    this.onContextMenuEatWhole,
    this.onContextMenuDelete,
  });

  @override
  _FridgeItemRowState createState() => _FridgeItemRowState();
}

class _FridgeItemRowState extends State<FridgeItemRow> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.transparent,
      child: CupertinoContextMenu.builder(
        actions: [
          CupertinoContextMenuAction(
            child: Text("Open"),
            trailingIcon: FontAwesomeIcons.folderOpen,
            onPressed: () {
              context.pop();
              context.push(
                "/fridge/items/${widget.fridgeItem.id}",
                extra: widget.fridgeItem,
              );
            },
          ),
          CupertinoContextMenuAction(
            child: Text("Consume whole"),
            trailingIcon: FontAwesomeIcons.cookieBite,
            onPressed: () {
              widget.onContextMenuEatWhole!();
              context.pop();
            }
          ),
          CupertinoContextMenuAction(
            child: Text("Add the new one"),
            trailingIcon: FontAwesomeIcons.clone,
            onPressed: () {
              widget.onContextMenuDuplicate!();
              context.pop();
            },
          ),
          Container(
            height: 2,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          CupertinoContextMenuAction(
            isDestructiveAction: true,
            child: Text("Delete from fridge"),
            trailingIcon: FontAwesomeIcons.trashCan,
            onPressed: () {
              widget.onContextMenuDelete!();
              context.pop();
            },
          ),
        ],
        builder: (context, animation) {
          return Container(
            margin: const EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 10.0,
            ),
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HavkaColors.bone[100]!),
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                tileColor: Colors.transparent,
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: <Widget>[
                      if (widget.fridgeItem.product.images != null)
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image: NetworkImage(
                                widget.fridgeItem.product.images!
                                    .original!,
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        )
                      else
                        const Center(
                          child: Icon(
                            HavkaIcons.bowl,
                            color: HavkaColors.energy,
                          ),
                        ),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: HavkaCircularProgressBar(
                          value: widget.fridgeItem.amount.value > 0.01
                              ? widget.fridgeItem.amount.value /
                              widget.fridgeItem.initialAmount.value
                              : 0.01,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(
                  widget.fridgeItem.product.name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme
                      .of(context)
                      .textTheme
                      .labelLarge,
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.fridgeItem.product.nutrition != null
                      ? SizedBox(
                        height: 20,
                        width: 200,
                        child: NutritionInfo(
                          product: widget.fridgeItem.product,
                        ),
                      )
                      : Container(
                        height: 20,
                        width: 200,
                        decoration: BoxDecoration(
                          color: HavkaColors.kcal.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        )
                      ),
                    Text(
                      widget.fridgeItem.amount.value > 0.01
                          ? '${formatNumber(widget.fridgeItem.amount.value)} '
                          '${widget.fridgeItem.amount.unit}'
                          : "0 g",
                      style: Theme
                          .of(context)
                          .textTheme
                          .labelSmall,
                    )
                  ],
                ),
                onTap: () {
                  context.push(
                    "/fridge/items/${widget.fridgeItem.id}",
                    extra: widget.fridgeItem,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmptyFridgeItem extends StatelessWidget {
  const EmptyFridgeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HavkaColors.bone[100]!),
        ),
        child: ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xff7c94b6),
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  ),
                ),
                const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressBar(value: -1),
                )
              ],
            ),
          ),
          title: const SizedBox(
            width: 30,
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.green,
              ),
            ),
          ),
          subtitle: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Colors.green,
            ),
            width: 20,
            height: 9,
          ),
        ),
      ),
    );
  }
}
