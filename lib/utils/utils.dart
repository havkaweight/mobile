import 'package:flutter/material.dart';
import 'package:health_tracker/model/data_items.dart';
import 'package:health_tracker/model/user_consumption_item.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  if (dateTime.toLocal().year == DateTime.now().year &&
      dateTime.toLocal().month == DateTime.now().month &&
      dateTime.toLocal().day == DateTime.now().day) {
    return 'Today ${DateFormat('HH:mm').format(dateTime.toLocal())}';
  } else if (dateTime.toLocal().year == DateTime.now().year &&
      dateTime.toLocal().month == DateTime.now().month &&
      dateTime.toLocal().day ==
          DateTime.now().subtract(const Duration(days: 1)).day) {
    return 'Yesterday ${DateFormat('HH:mm').format(dateTime.toLocal())}';
  }
  return DateFormat('dd MMM HH:mm').format(dateTime.toLocal());
}

String showUsername(String username) {
  const showingLength = 13;
  if (username.length > showingLength) {
    return '@${username.substring(0, showingLength)}...';
  }
  return '@$username';
}

List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  final List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

List<DataItem> userConsumptionToBarChartData(
    List<UserConsumptionItem> userConsumption) {
  final DateTime currentDate = DateTime.now();
  final DateTime maxDate =
      DateTime(currentDate.year, currentDate.month, currentDate.day);
  final DateTime minDate = maxDate.subtract(const Duration(days: 6));
  final List<DateTime> datesPeriod = getDaysInBetween(minDate, maxDate);
  final List<DataItem> weightsData = [];
  for (final DateTime date in datesPeriod) {
    weightsData.add(
      DataItem(
        userConsumption.fold(0, (previousValue, element) {
          if ((element.consumedAt ?? element.createdAt)!
                      .difference(date)
                      .inDays ==
                  0 &&
              (element.consumedAt ?? element.createdAt)!.isAfter(date)) {
            return previousValue += element.amount!.value;
          }
          return previousValue;
        }),
        DateFormat('MMM d').format(date),
        Colors.amber[500]!,
      ),
    );
  }
  return weightsData;
}
