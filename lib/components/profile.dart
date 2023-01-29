import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/widgets/rounded_button.dart';
import '../ui/widgets/screen_header.dart';


class ProfileHeader extends StatelessWidget {
  final String? username;
  final int? height;
  final double? weight;
  final String? photoUrl;

  const ProfileHeader({
    this.username,
    this.height,
    this.weight,
    this.photoUrl
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                photoUrl!,
                width: MediaQuery.of(context).size.width * 0.3,
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(username!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                          children: <Widget>[
                            const Icon(
                              Icons.height_outlined,
                              size: 25,
                            ),
                            Text(
                                '${height.toString()} cm',
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ]
                      ),
                      Row(
                          children: <Widget>[
                            const Icon(
                              Icons.monitor_weight_outlined,
                              size: 25,
                            ),
                            Text(
                              '${weight.toString()} kg',
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ]
                      ),
                    ]
                  ),
                  // Text(
                  //   'Height: ${height.toString()}',
                  // ),
                  // Text(
                  //   'Weight: ${weight.toString()}',
                  // ),
                  // IconButton(
                  //     icon: const Icon(Icons.logout),
                  //     onPressed: onPressed
                  // ),
                ]),
          ),
        ]));
  }
}
