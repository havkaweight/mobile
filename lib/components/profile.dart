import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final double height;
  final double weight;
  final String photoUrl;
  final Function onPressed;

  const ProfileHeader({
    this.username,
    this.height,
    this.weight,
    this.photoUrl,
    this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: Image.network(
                photoUrl,
                width: MediaQuery.of(context).size.width * 0.3,
              )
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    username,
                    style: TextStyle(
                      fontFamily: 'Itim',
                      fontSize: 15
                    )
                  ),
                  Text(
                    'Height: ${height.toString()}',
                  ),
                  Text(
                    'Weight: ${weight.toString()}',
                  )
                ]
              ),
            ),
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: onPressed
            )
          ]
        )
    );
  }
}