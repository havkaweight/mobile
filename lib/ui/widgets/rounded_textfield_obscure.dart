import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class RoundedTextFieldObscured extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final double? width;
  final Color? color;
  final Icon? icon;
  final bool? obscureText;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final void Function(String)? onSubmitted;

  const RoundedTextFieldObscured({
    Key? key,
    this.labelText,
    this.hintText,
    this.width = 0.7,
    this.icon,
    this.color,
    this.controller,
    this.focusNode,
    this.errorText,
    this.obscureText = true,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.onSubmitted
  }) : super(key: key);

  @override
  _RoundedTextFieldObscuredState createState() => _RoundedTextFieldObscuredState();
}

class _RoundedTextFieldObscuredState extends State<RoundedTextFieldObscured> {
  bool? _isHidden;
  bool _isIconShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.obscureText!) {
      _isHidden = true;
      widget.controller!.addListener(_checkField);
    } else {
      _isHidden = false;
    }
  }

  void _checkField() {
    setState(() {
      widget.controller!.text.isNotEmpty
          ? _isIconShown = true
          : _isIconShown = false;
    });
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double mWidth = MediaQuery.of(context).size.width;
    return Container(
      width: widget.width! * mWidth,
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15.0),
      child: TextField(
        obscureText: _isHidden!,
        onSubmitted: widget.onSubmitted,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        autofocus: widget.autoFocus!,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          suffixIcon: widget.obscureText!
            ? IconButton(
                icon: _isIconShown
                  ? Icon(
                      _isHidden!
                        ? Icons.visibility
                        : Icons.visibility_off,
                      color: HavkaColors.green
                    )
                  : const Icon(null),
                onPressed: _togglePasswordView,
              )
            : null,
          fillColor: const Color(0xFFEDE88E),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: const Color(0xFFFFFFFF),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF5BBE78), width: 3.0),
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
          hintText: widget.controller!.text.isEmpty ? widget.hintText : widget.controller!.text,
          errorText: widget.errorText,
          // labelText: controller.text.isEmpty ? labelText : controller.text,
          hintStyle: const TextStyle(
            color: Color(0x7A66550B),
            // fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        )
      )
    );
  }
}
