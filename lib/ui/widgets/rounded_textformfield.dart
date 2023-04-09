import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class HavkaTextFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final double? width;
  final Color? color;
  final IconButton? iconButton;
  final bool? obscureText;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final void Function(String)? onSubmitted;
  final void Function(PointerDownEvent)? onTapOutside;
  final TextAlign? textAlign;

  const HavkaTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.width = 1,
    this.iconButton,
    this.color,
    this.controller,
    this.focusNode,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.onSubmitted,
    this.onTapOutside,
    this.textAlign = TextAlign.start,
  });

  @override
  HavkaTextFormFieldState createState() => HavkaTextFormFieldState();
}

class HavkaTextFormFieldState extends State<HavkaTextFormField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      child: TextFormField(
        textAlign: widget.textAlign!,
        onTapOutside: widget.onTapOutside,
        focusNode: widget.focusNode,
        obscureText: widget.obscureText!,
        keyboardType: widget.keyboardType,
        autofocus: widget.autoFocus!,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          suffixIcon: widget.iconButton,
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
          // labelText: controller.text.isEmpty ? labelText : controller.text,
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
