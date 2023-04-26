import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_tracker/constants/colors.dart';

class RoundedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final double? width;
  final Color? color;
  final Icon? prefixIcon;
  final IconButton? iconButton;
  final String? suffixText;
  final bool? obscureText;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted;
  final TextAlign? textAlign;

  const RoundedTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.width = 1,
    this.prefixIcon,
    this.suffixText,
    this.iconButton,
    this.color,
    this.controller,
    this.focusNode,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onSubmitted,
    this.textAlign = TextAlign.start,
  });

  @override
  RoundedTextFieldState createState() => RoundedTextFieldState();
}

class RoundedTextFieldState<T extends RoundedTextField>
    extends State<RoundedTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      child: TextField(
        textAlign: widget.textAlign!,
        onSubmitted: widget.onSubmitted,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText!,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autoFocus!,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.iconButton,
          suffixText: widget.suffixText,
          fillColor: HavkaColors.bone[100],
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
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
          hintText: widget.controller!.text.isEmpty
              ? widget.hintText
              : widget.controller!.text,
          errorText: widget.errorText,
          hintStyle: const TextStyle(
            color: Color(0x7A66550B),
            // fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
