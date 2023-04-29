import 'package:flutter/material.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:health_tracker/ui/widgets/progress_indicator.dart';
import 'package:health_tracker/utils/utils.dart';

class UserConsumptionScreen extends StatefulWidget {
  @override
  _UserConsumptionScreenState createState() => _UserConsumptionScreenState();
}

class _UserConsumptionScreenState extends State<UserConsumptionScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();
  ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();
  List<UserConsumptionItem>? userConsumption;
  late ValueNotifier<List<UserConsumptionItem>?> userConsumptionListener;

  @override
  void initState() {
    super.initState();
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
    final double mHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: mHeight * 0.82,
                child: NotificationListener<ScrollNotification>(
                  child: ValueListenableBuilder(
                    valueListenable: userConsumptionListener,
                    builder: (
                      BuildContext context,
                      List<UserConsumptionItem>? value,
                      _,
                    ) {
                      if (value == null) {
                        return const Center(child: HavkaProgressIndicator());
                      }
                      return ListView.builder(
                        physics: scrollPhysics,
                        itemCount: userConsumption!.length,
                        itemBuilder: (BuildContext context, index) {
                          userConsumption!.sort(
                            (a, b) => (b.consumedAt ?? b.createdAt!)
                                .compareTo(a.consumedAt ?? a.createdAt!),
                          );
                          final UserConsumptionItem userConsumptionItem =
                              userConsumption![index];
                          return ListTile(
                            title: Text(
                              userConsumptionItem.product!.name!,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            subtitle: Text(
                              formatDate(
                                userConsumptionItem.consumedAt ??
                                    userConsumptionItem.createdAt!,
                              ),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            trailing: Text(
                              '${userConsumptionItem.amount!.value} ${userConsumptionItem.amount!.unit}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
