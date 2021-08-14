import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class SearchTextField extends StatefulWidget {
  final String labelText, hintText;
  final double width;
  final Color color;
  final Icon icon;
  final bool obscureText;
  final bool autoFocus;
  final String errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const SearchTextField({
    Key key,
    this.labelText,
    this.hintText,
    this.width = 0.7,
    this.icon,
    this.color,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text
  }) : super(key: key);

  @override
  SearchTextFieldState createState() => SearchTextFieldState();
}

class SearchTextFieldState<T extends SearchTextField> extends State<SearchTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    return Container(
      width: widget.width * mWidth,
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        autofocus: widget.autoFocus,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          fillColor: HavkaColors.bone,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(15.0),
          ),
          focusColor: const Color(0xFFFFFFFF),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: HavkaColors.green, width: 3.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF0000), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFFF0000), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: widget.controller.text.isEmpty ? widget.hintText : widget.controller.text,
          errorText: widget.errorText,
          prefixIcon: widget.icon,
          hintStyle: const TextStyle(
            color: Color(0x7A66550B),
            fontSize: 14
          ),
        )
      )
    );
  }
}