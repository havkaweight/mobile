import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/constants/colors.dart';
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: <Widget>[
                            Row(
                              children: [
                                const FaIcon(
                                  FontAwesomeIcons.rulerVertical,
                                  color: Colors.black,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
                                  child: Text(
                                    '${height.toString()} cm',
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                const FaIcon(
                                  FontAwesomeIcons.weightScale,
                                  color: Colors.black,
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Text(
                                    '${weight.toString()} kg',
                                    style: const TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
