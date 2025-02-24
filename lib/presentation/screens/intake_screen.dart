import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '/core/constants/colors.dart';
import '/data/models/pfc_data_item.dart';
import '../widgets/charts/stack_bar_chart.dart';


class IntakeScreen extends StatefulWidget {
  const IntakeScreen({Key? key}) : super(key: key);

  @override
  _IntakeScreenState createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen>
    with TickerProviderStateMixin {

  List _items = [];
  final ScrollController _screenScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _items = [
      {"tag": "breakfast"},
      {"tag": "lunch"},
      {"tag": "dinner"},
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      "Edit",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      WidgetStatePropertyAll<Color>(
                          Colors.black.withValues(alpha: 0.05)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).viewPadding.top
                  - 60,
              child: Scrollbar(
                controller: _screenScrollController,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: SingleChildScrollView(
                    controller: _screenScrollController,
                    child: Column(
                      children: [
                        Container(
                          height: 900,
                          child: ReorderableListView.builder(
                            onReorder: (int oldIndex, int newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final item = _items.removeAt(oldIndex);
                                _items.insert(newIndex, item);
                              });
                            },
                            itemCount: _items.length,
                            itemBuilder: (BuildContext context, int index) =>
                              Container(
                                key: UniqueKey(),
                                height: 250,
                                margin: EdgeInsets.symmetric(vertical: 10.0),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: HavkaColors.energy.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                alignment: AlignmentDirectional.centerStart,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.0,
                                        vertical: 3.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: HavkaColors.energy.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(5.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 10.0),
                                            child: Transform.rotate(
                                              angle: 3 * pi / 4,
                                              child: Icon(
                                                FontAwesomeIcons.tag,
                                                color: HavkaColors.energy.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _items[index]["tag"],
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: HavkaColors.energy,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: HavkaStackBarChart(
                                        initialData: [
                                          PFCDataItem(value: 100, label: "Protein", color: HavkaColors.protein),
                                          PFCDataItem(value: 200, label: "Fat", color: HavkaColors.fat),
                                          PFCDataItem(value: 300, label: "Carbs", color: HavkaColors.carbs),
                                        ],
                                        showLegend: false,
                                        onTapBar: (_) {},
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            proxyDecorator: (child, index, animation) => AnimatedBuilder(
                              animation: animation,
                              builder: (BuildContext context, Widget? child) {
                                return PhysicalModel(
                                  color: HavkaColors.energy.withValues(alpha: 0.05),
                                  elevation: 5,
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: child,
                                );
                              },
                              child: child,
                            ),
                            ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 10.0,
                              bottom: 40.0,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: HavkaColors.energy.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Icon(
                              Icons.add,
                              color: HavkaColors.energy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
