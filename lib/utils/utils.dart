import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:havka/utils/get_days_from_period.dart';
import '../data/models/data_item.dart';
import '/data/models/pfc_data_item.dart';
import '../domain/entities/consumption/user_consumption_item.dart';
import 'package:intl/intl.dart';


List<DataItem> userConsumptionToBarChartData(
  List<UserConsumptionItem> userConsumption,
) {
  final DateTime currentDate = DateTime.now();
  final DateTime maxDate =
      DateTime(currentDate.year, currentDate.month, currentDate.day);
  final DateTime minDate = maxDate.subtract(const Duration(days: 6));
  final List<DateTime> datesPeriod = getDaysFromPeriod(minDate, maxDate);
  final List<DataItem> weightsData = [];
  for (final DateTime date in datesPeriod) {
    weightsData.add(
      DataItem(
        userConsumption.fold(0, (previousValue, element) {
          if (element.consumedAt
                      .difference(date)
                      .inDays == 0 &&
              element.consumedAt.isAfter(date)) {
            return previousValue += element.consumedAmount!.value;
          }
          return previousValue;
        }),
        DateFormat('MMM d').format(date),
        date,
        Colors.amber[500]!,
      ),
    );
  }
  return weightsData;
}


Map<String, dynamic> decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!"');
  }

  return jsonDecode(utf8.decode(base64Url.decode(output)));
}