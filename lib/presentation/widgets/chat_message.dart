import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/core/constants/colors.dart';

enum MessageType { incoming, outgoing }

class Message extends StatelessWidget {
  final MessageType messageType;
  final String text;
  final Timestamp timestamp;

  Message({
    this.messageType = MessageType.outgoing,
    required this.text,
    required this.timestamp,
  });

  DateTime get dt => DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: switch (messageType) {
        MessageType.outgoing =>
          AlignmentDirectional.centerEnd,
        MessageType.incoming =>
          AlignmentDirectional.centerStart,
      },
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: switch (messageType) {
            MessageType.outgoing =>
                HavkaColors.energy.withValues(alpha: 0.2),
            MessageType.incoming =>
                HavkaColors.black.withValues(alpha: 0.1),
          },
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0),
              child: Text(
                DateFormat("HH:mm").format(dt.toLocal()),
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}