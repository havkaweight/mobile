class Utils {

  String listIntToString(List<int> valueList) {
    final buffer = StringBuffer();
    for (final int element in valueList) {
      buffer.write(String.fromCharCode(element));
    }
    final String valueString = buffer.toString();
    return valueString;
  }
}