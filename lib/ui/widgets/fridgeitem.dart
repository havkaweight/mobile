import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:health_tracker/ui/screens/scale_screen.dart';
import 'package:health_tracker/ui/widgets/circular_progress_bar.dart';
import 'package:health_tracker/ui/widgets/nutrition_line.dart';

class FridgeItem extends StatefulWidget {
  final UserProduct userProduct;
  final List<UserConsumptionItem>? userConsumption;
  final Function()? onPressed;

  const FridgeItem({
    super.key,
    required this.userProduct,
    this.userConsumption,
    this.onPressed,
  });

  @override
  _FridgeItemState createState() => _FridgeItemState();
}

class _FridgeItemState extends State<FridgeItem> {
  double dragDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          dragDistance += details.delta.dx;
          if (dragDistance < -50.0) {
            dragDistance = -50.0;
          }
          if (dragDistance > 0) {
            dragDistance = 0.0;
          }
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          if (dragDistance < -25) {
            dragDistance = -50.0;
          } else {
            dragDistance = 0.0;
          }
        });
      },
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(dragDistance, 0.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 10.0,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: HavkaColors.bone[100]!),
                ),
                child: ListTile(
                  tileColor: Colors.transparent,
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      children: <Widget>[
                        if (widget.userProduct.product!.img != null)
                          Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xff7c94b6),
                              image: DecorationImage(
                                image: NetworkImage(
                                  widget.userProduct.product!.img!,
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50.0),
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Icon(
                              FontAwesomeIcons.bowlFood,
                              color: HavkaColors.kcal,
                            ),
                          ),
                        const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressBar(
                            value: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    widget.userProduct.product?.name ?? 'NAME Placeholder',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.userProduct.product?.nutrition != null)
                        SizedBox(
                          height: 20,
                          width: 150,
                          child: buildNutritionLine(
                            widget.userProduct.product?.nutrition,
                          ),
                        )
                      else
                        const SizedBox(
                          height: 20,
                        ),
                      Text(
                        widget.userProduct.amount != null ||
                                widget.userProduct.amount!.value > 0.01
                            ? '${widget.userProduct.amount!.value.toInt()} ${widget.userProduct.amount!.unit}'
                            : '0 g',
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScaleScreen(
                          userProduct: widget.userProduct,
                          userConsumption: widget.userConsumption,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(
              MediaQuery.of(context).size.width + dragDistance,
              0.0,
            ),
            child: SizedBox(
              width: 40,
              height: 80,
              child: Center(
                child: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  splashColor: Colors.transparent,
                  onPressed: widget.onPressed,
                ),
              ),
            ),
          ),
        ],
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
