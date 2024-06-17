import 'dart:convert';
import 'dart:developer';
import 'dart:math';
import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/constants/fridge_sort.dart';
import 'package:havka/model/data_items.dart';
import 'package:havka/model/fridge_data_model.dart';
import 'package:havka/model/product.dart';
import 'package:havka/model/product_amount.dart';
import 'package:havka/model/profile_data_model.dart';
import 'package:havka/model/user_consumption_item.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:havka/ui/screens/fridge_adjustment_screen.dart';
import 'package:havka/ui/screens/havka_barcode_scanner.dart';
import 'package:havka/ui/screens/havka_receipt_scanner.dart';
import 'package:havka/ui/screens/product_adjustment_screen.dart';
import 'package:havka/ui/screens/products_screen.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/widgets/donut_chart.dart';
import 'package:havka/ui/widgets/fridgeitem.dart';
import 'package:havka/ui/widgets/holder.dart';
import 'package:havka/ui/widgets/modal_scale.dart';
import 'package:havka/ui/widgets/screen_header.dart';
import 'package:havka/ui/widgets/shimmer.dart';
import 'package:havka/ui/widgets/stack_bar_chart.dart';
import 'package:havka/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/utils.dart';
import '../../model/fridge.dart';
import '../widgets/progress_indicator.dart';
import 'authorization.dart';
import 'main_screen.dart';

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({Key? key}) : super(key: key);

  @override
  _IntakeScreenState createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen>
    with TickerProviderStateMixin {
  final ApiRoutes _apiRoutes = ApiRoutes();

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
                      MaterialStatePropertyAll<Color>(
                          Colors.black.withOpacity(0.05)),
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
                                  color: HavkaColors.energy.withOpacity(0.05),
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
                                        color: HavkaColors.energy.withOpacity(0.1),
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
                                                color: HavkaColors.energy.withOpacity(0.5),
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
                                  color: HavkaColors.energy.withOpacity(0.05),
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
                              color: HavkaColors.energy.withOpacity(0.05),
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
