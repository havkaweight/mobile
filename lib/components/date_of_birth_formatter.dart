import 'package:flutter/services.dart';

class DateOfBirthFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    switch (newValue.text.length) {
      case 1:
        if(!RegExp(r'\b([0-3])\b').hasMatch(newValue.text)) {
          return oldValue;
        }
        return newValue;
      case 2:
        if(!RegExp(r'\b(0[1-9]|[12][0-9]|3[01])\b').hasMatch(newValue.text)) {
          return oldValue;
        }
        if(oldValue.text.length > 2) {
          final String newText = newValue.text.substring(0, newValue.text.length-1);
          return newValue.copyWith(
              text: newText,
              selection: TextSelection.fromPosition(TextPosition(offset: newText.length))
          );
        }
        final String newText = '${newValue.text}.';
        return newValue.copyWith(
            text: newText,
            selection: TextSelection.fromPosition(TextPosition(offset: newText.length))
        );
      case 3:
        if (oldValue.text.length > 3) {
          final String newText = newValue.text.substring(0, newValue.text.length);
          return newValue.copyWith(
              text: newText,
              selection: TextSelection.fromPosition(TextPosition(offset: newText.length))
          );
        }
        return newValue;
      case 4:
        if(!RegExp(r'\b([01])\b').hasMatch(newValue.text.substring(newValue.text.length-1))) {
          return oldValue;
        }
        return newValue;
      case 5:
        if(!RegExp(r'\b(0[1-9]|1[0-2])\b').hasMatch(newValue.text.substring(newValue.text.length-2))) {
          return oldValue;
        }
        if(oldValue.text.length > 5) {
          final String newText = newValue.text.substring(0, newValue.text.length-1);
          return newValue.copyWith(
              text: newText,
              selection: TextSelection.fromPosition(TextPosition(offset: newText.length))
          );
        }
        final String newText = '${newValue.text}.';
        return newValue.copyWith(
            text: newText,
            selection: TextSelection.fromPosition(TextPosition(offset: newText.length))
        );
      case 6:
        if (oldValue.text.length > 6) {
          final String newText = newValue.text.substring(0, newValue.text.length);
          return newValue.copyWith(
              text: newText,
              selection: TextSelection.fromPosition(TextPosition(offset: newText.length))
          );
        }
        return newValue;
      case 7:
        if(!RegExp(r'\b([12])\b').hasMatch(newValue.text.substring(newValue.text.length-1))) {
          return oldValue;
        }
        return newValue;
      case 8:
        if(!RegExp(r'\b(19|20)\b').hasMatch(newValue.text.substring(newValue.text.length-2))) {
          return oldValue;
        }
        return newValue;
      case 9:
        if(!RegExp(r'\b(19[0-9]|20[0-9])\b').hasMatch(newValue.text.substring(newValue.text.length-3))) {
          return oldValue;
        }
        return newValue;
      case 10:
        if(!RegExp(r'\b(19[0-9][0-9]|20[0-9][0-9])\b').hasMatch(newValue.text.substring(newValue.text.length-4))) {
          return oldValue;
        }
        return newValue;
      case _:
        return newValue;
    }
  }
}
