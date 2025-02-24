import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final Timestamp timestamp;

  Message({
    required this.text,
    required this.timestamp,
  });
}