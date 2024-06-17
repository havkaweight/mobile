import 'package:flutter/material.dart';
import 'package:havka/constants/colors.dart';

class SearchTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final double? width;
  final Color? color;
  final Color? fillColor;
  final Icon? icon;
  final bool? obscureText;
  final bool? autoFocus;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  const SearchTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.width = 0.7,
    this.icon,
    this.color,
    this.fillColor = const Color(0x0D000000),
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  SearchTextFieldState createState() => SearchTextFieldState();
}

class SearchTextFieldState<T extends SearchTextField>
    extends State<SearchTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    return Container(
      // width: widget.width! * mWidth,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        obscureText: widget.obscureText!,
        keyboardType: widget.keyboardType,
        autofocus: widget.autoFocus!,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          fillColor: widget.fillColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(50.0),
          ),
          focusColor: const Color(0xFFFFFFFF),
          hintText: widget.controller!.text.isEmpty
              ? widget.hintText
              : widget.controller!.text,
          errorText: widget.errorText,
          prefixIcon: widget.icon,
          hintStyle: const TextStyle(
            color: Color(0x7A66550B),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
