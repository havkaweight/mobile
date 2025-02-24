import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String text;
  final Timestamp timestamp;

  MessageModel({
    required this.text,
    required this.timestamp,
  });

  DateTime get dt => DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
}