import 'package:intl/intl.dart';

String formatDate(DateTime dateTime) {
  if (dateTime.toLocal().year == DateTime.now().year &&
      dateTime.toLocal().month == DateTime.now().month &&
      dateTime.toLocal().day == DateTime.now().day) {
    return "${DateFormat('HH:mm').format(dateTime.toLocal())}";
  } else if (dateTime.toLocal().year == DateTime.now().year &&
      dateTime.toLocal().month == DateTime.now().month &&
      dateTime.toLocal().day ==
          DateTime.now().subtract(const Duration(days: 1)).day) {
    return "Yesterday ${DateFormat('HH:mm').format(dateTime.toLocal())}";
  }
  return DateFormat("d MMM HH:mm").format(dateTime.toLocal());
}