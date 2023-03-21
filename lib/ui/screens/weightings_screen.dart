import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/methods.dart';
import '../../model/user_product_weighting.dart';
import '../../ui/widgets/progress_indicator.dart';

class WeightingsScreen extends StatefulWidget {
  @override
  _WeightingsScreenState createState() => _WeightingsScreenState();
}

class _WeightingsScreenState extends State<WeightingsScreen> {
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
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1), (_) => Random().nextInt(300)),
                builder: (context, snapshot) {
                  return Hero(
                      tag: 'mini-scale',
                      child: Text('${snapshot.data ?? 10}g')
                  );
              // FutureBuilder<List<UserProductWeighting>>(
              //   future: _apiRoutes.getWeightingsHistory(),
              //   builder: (
              //     BuildContext context,
              //     AsyncSnapshot<List<UserProductWeighting>> snapshot,
              //   ) {
              //     if (!snapshot.hasData) {
              //       return Center(
              //         child: Container(
              //           padding: const EdgeInsets.symmetric(vertical: 40.0),
              //           child: const HavkaProgressIndicator(),
              //         ),
              //       );
              //     }
              //     if (snapshot.hasData) {
              //       final double mHeight = MediaQuery.of(context).size.height;
              //       if (snapshot.data!.isNotEmpty) {
              //         return SizedBox(
              //           height: mHeight * 0.82,
              //           child: ListView.builder(
              //               itemCount: snapshot.data!.length,
              //               itemBuilder: (BuildContext context, index) {
              //                 final UserProductWeighting userProductWeighting =
              //                     snapshot.data![index];
              //                 final createdAt = DateFormat('yyyy-MM-dd kk:mm')
              //                     .format(userProductWeighting.createdAt!);
              //                 return ListTile(
              //                   title: Text(
              //                     '${userProductWeighting.userProductWeight.toString()} ${userProductWeighting.userProductUnit}',
              //                     style: const TextStyle(fontWeight: FontWeight.bold),
              //                   ),
              //                   subtitle: Text(userProductWeighting.userProductName!,
              //                       style: TextStyle(
              //                           fontSize: Theme.of(context)
              //                               .textTheme
              //                               .headline4!
              //                               .fontSize)),
              //                   trailing: Text(createdAt,
              //                       style: TextStyle(
              //                           fontSize: Theme.of(context)
              //                               .textTheme
              //                               .headline4!
              //                               .fontSize)),
              //                   onTap: () {
              //                     Navigator.pop(context);
              //                   },
              //                 );
              //               }),
              //         );
              //       } else {
              //         return SizedBox(
              //             height: mHeight * 0.82,
              //             child: const Center(child: Text('History not found')));
              //       }
              //     }
              //     return const Center(child: Text('Error internet connection'));
              //   },
              // )
            }),
            ]),
        ),
    );
  }
}
