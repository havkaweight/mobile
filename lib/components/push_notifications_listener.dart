import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HavkaNotificationListener extends StatelessWidget {

  final Widget child;

  HavkaNotificationListener({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RemoteMessage>(
      stream: FirebaseMessaging.onMessage,
      builder: (BuildContext context, AsyncSnapshot<RemoteMessage> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final RemoteNotification? message = snapshot.data?.notification;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Title: ${message?.title}, Body: ${message?.body}'),
          ),
        );
        return child; // Or your main app widget
      },
    );
  }
}