import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ui/widgets/rounded_button.dart';
import '../ui/widgets/screen_header.dart';

class ProfileHeader extends StatelessWidget {
  final String? username;
  final double? height;
  final double? weight;
  final String? photoUrl;
  final void Function()? onPressed;

  const ProfileHeader(
      {this.username, this.height, this.weight, this.photoUrl, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.network(
                photoUrl!,
                width: MediaQuery.of(context).size.width * 0.3,
              )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(username!,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Height: ${height.toString()}',
                  ),
                  Text(
                    'Weight: ${weight.toString()}',
                  ),
                  // IconButton(
                  //     icon: const Icon(Icons.logout),
                  //     onPressed: onPressed
                  // ),
                  RoundedButton(text: 'Log out', onPressed: onPressed)
                ]),
          ),
        ]));
  }
}
