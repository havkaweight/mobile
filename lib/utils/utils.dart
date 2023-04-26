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
