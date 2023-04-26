import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileHeader extends StatelessWidget {
  final String? username;
  final int? height;
  final double? weight;
  final String? photoUrl;

  const ProfileHeader({this.username, this.height, this.weight, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              photoUrl!,
              width: MediaQuery.of(context).size.width * 0.3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  username!,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    children: <Widget>[
                      Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.rulerVertical,
                            color: Colors.black,
                            size: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              8,
                              0,
                              20,
                              0,
                            ),
                            child: Text(
                              '$height cm',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          const FaIcon(
                            FontAwesomeIcons.weightScale,
                            color: Colors.black,
                            size: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              8,
                              0,
                              0,
                              0,
                            ),
                            child: Text(
                              '${weight!} kg',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
