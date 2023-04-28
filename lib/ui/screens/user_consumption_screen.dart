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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List<UserConsumptionItem>>(
              future: _apiRoutes.getUserConsumption(),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<UserConsumptionItem>> snapshot,
              ) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: HavkaProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  final double mHeight = MediaQuery.of(context).size.height;
                  if (snapshot.data!.isNotEmpty) {
                    return SizedBox(
                      height: mHeight * 0.82,
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, index) {
                            snapshot.data!.sort(
                              (a, b) => (b.consumedAt ?? b.createdAt!)
                                  .compareTo(a.consumedAt ?? a.createdAt!),
                            );
                            final UserConsumptionItem userConsumptionItem =
                                snapshot.data![index];
                            return ListTile(
                              title: Text(
                                userConsumptionItem.product!.name!,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
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
                          }),
                    );
                  } else {
                    return SizedBox(
                        height: mHeight * 0.82,
                        child: const Center(child: Text('History not found')));
                  }
                }
                return const Center(child: Text('Error internet connection'));
              },
            )
          ],
        ),
      ),
    );
  }
}
