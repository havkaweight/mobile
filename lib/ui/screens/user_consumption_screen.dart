import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/model/user_consumption_item.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/utils/utils.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import '../../constants/utils.dart';
import '../widgets/holder.dart';

class UserConsumptionScreen extends StatefulWidget {
  @override
  _UserConsumptionScreenState createState() => _UserConsumptionScreenState();
}

class _UserConsumptionScreenState extends State<UserConsumptionScreen>
    with SingleTickerProviderStateMixin {
  final ApiRoutes _apiRoutes = ApiRoutes();
  List<UserConsumptionItem>? userConsumption;
  late ValueNotifier<List<UserConsumptionItem>?> userConsumptionListener;

  late AnimationController _swipingController;

  double minChildSize = 0.5;
  double maxChildSize = 0.85;

  final ScrollController _listScrollController = ScrollController();
  late Offset _appBarOffset;
  late double _appBarBlurRadius;

  @override
  void initState() {
    super.initState();

    _appBarOffset = Offset.zero;
    _appBarBlurRadius = 0.0;

    _listScrollController.addListener(() {
      if (_listScrollController.position.pixels <= 0.0) {
        setState(() {
          _appBarOffset = Offset.zero;
          _appBarBlurRadius = 0.0;
        });
      } else if (_listScrollController.position.pixels > 5.0) {
        setState(() {
          _appBarOffset = Offset(0.0, 2.0);
          _appBarBlurRadius = 1.0;
        });
      } else {
        setState(() {
          _appBarOffset = Offset(0.0, _listScrollController.position.pixels / 2.5);
          _appBarBlurRadius = _listScrollController.position.pixels / 5.0;
        });
      }
    });

    _swipingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    userConsumptionListener = ValueNotifier(userConsumption);
    () async {
      userConsumption = await _apiRoutes.getUserConsumption();
      userConsumptionListener.value = userConsumption;
    }();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: maxChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) {
          scrollController.addListener(() {
            if (scrollController.position.pixels <= 0.0) {
              setState(() {
                _appBarOffset = Offset.zero;
                _appBarBlurRadius = 0.0;
              });
            } else if (scrollController.position.pixels > 5.0) {
              setState(() {
                _appBarOffset = Offset(0.0, 2.0);
                _appBarBlurRadius = 1.0;
              });
            } else {
              setState(() {
                _appBarOffset = Offset(0.0, scrollController.position.pixels / 2.5);
                _appBarBlurRadius = scrollController.position.pixels / 5.0;
              });
            }
          });
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), // Adjust the radius as needed
              topRight: Radius.circular(20.0),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: HavkaColors.cream,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: _appBarOffset,
                        blurRadius: _appBarBlurRadius,
                      ),
                    ],
                  ),
                  child: Holder(
                    height: 30,
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    controller: _listScrollController,
                    child: SingleChildScrollView(
                      controller: _listScrollController,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.85 - 30,
                        child: ValueListenableBuilder(
                          valueListenable: userConsumptionListener,
                          builder: (
                            BuildContext context,
                            List<UserConsumptionItem>? value,
                            _,
                          ) {
                            if (value == null) {
                              return const Center(
                                  child: HavkaProgressIndicator());
                            }
                            userConsumption!.sort(
                                  (a, b) =>
                                  (b.consumedAt).compareTo(a.consumedAt),
                            );
                            final userConsumptionGroups = groupBy(userConsumption!, (el) => DateFormat("yyyy-MM-dd").format(el.consumedAt)).entries.map((entry) => {entry.key: entry.value}).toList();
                            return NotificationListener<DraggableScrollableNotification>(
                              // onNotification: (notification) {
                              //   return notification.extent < notification.minExtent;
                              // },
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount: userConsumptionGroups.length,
                                itemBuilder: (BuildContext context, index) {
                                  final userConsumptionGroup = userConsumptionGroups[index];
                                  final String dateLabel = userConsumptionGroup.keys.first;
                                  final List<UserConsumptionItem> items = userConsumptionGroup.values.first;
                                  return Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 10.0),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.0,
                                            vertical: 5.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.03),
                                            borderRadius: BorderRadius.circular(50.0),
                                          ),
                                          child: Text(
                                            dateLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: items.length,
                                          itemBuilder: (context, groupIndex) {
                                            final UserConsumptionItem userConsumptionItem =
                                            items[groupIndex];
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 15.0,
                                                vertical: 10.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          Utils().cutString(userConsumptionItem
                                                              .product!.name!, 25),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          userConsumptionItem
                                                              .product!.brand!.name,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black
                                                                .withOpacity(0.5),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          "${Utils().formatNumber(userConsumptionItem.consumedAmount!.value)} ${userConsumptionItem.consumedAmount!.serving.name}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat("HH:mm").format(userConsumptionItem
                                                              .consumedAt),
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black
                                                                .withOpacity(0.5),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          }
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
