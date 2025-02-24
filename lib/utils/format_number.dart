dynamic formatNumber(double? number, {int decimal=0}) {
  return number == number!.toInt()
      ? number.toInt().toString()
      : number.toStringAsFixed(decimal);
}