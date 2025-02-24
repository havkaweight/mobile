class Utils {
  String listIntToString(List<int> valueList) {
    final buffer = StringBuffer();
    for (final int element in valueList) {
      buffer.write(String.fromCharCode(element));
    }
    final String valueString = buffer.toString();
    return valueString;
  }

  String? formatNumber(num? number) {
    if (number == null) {
      return null;
    }
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(1);
    }
  }

  String cutString(String str, int length) {
    return str.length > length ? "${str.substring(0, length-3)}..." : str;
  }

  bool areDatesEqual(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year &&
      dt1.month == dt2.month &&
      dt1.day == dt2.day;
  }
}
