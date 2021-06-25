import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/constants/colors.dart';

class RoundedTextField extends StatefulWidget {
  final String labelText, hintText;
  final Color color;
  final Icon icon;
  final bool obscureText;
  final bool autoFocus;
  final String errorText;
  final TextEditingController controller;
  const RoundedTextField({
    Key key,
    this.labelText,
    this.hintText,
    this.icon,
    this.color,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false
  }) : super(key: key);

  @override
  _RoundedTextFieldState createState() => _RoundedTextFieldState();
}

class _RoundedTextFieldState extends State<RoundedTextField> {
  bool _isHidden;
  bool _isIconShown = false;

  @override
  void initState() {
    super.initState();
    if (widget.obscureText) {
      _isHidden = true;
      widget.controller.addListener(_checkField);
    } else {
      _isHidden = false;
    }
  }

  _checkField() {
    setState(() {
      widget.controller.text.isNotEmpty
          ? _isIconShown = true
          : _isIconShown = false;
    });
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: size.width * 0.7,
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: TextField(
        obscureText: _isHidden,
        autofocus: widget.autoFocus,
        controller: widget.controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          suffixIcon: widget.obscureText
            ? IconButton(
                icon: _isIconShown
                  ? Icon(
                      _isHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                      color: HavkaColors.green
                    )
                  : Icon(null),
                onPressed: _togglePasswordView,
              )
            : null,
          fillColor: Color(0xFFEDE88E),
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusColor: Color(0xFFFFFFFF),
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
          hintText: widget.controller.text.isEmpty ? widget.hintText : widget.controller.text,
          errorText: widget.errorText,
          // labelText: controller.text.isEmpty ? labelText : controller.text,
          hintStyle: TextStyle(
            color: Color(0x7A66550B),
            // fontWeight: FontWeight.bold,
            fontSize: 16
          ),
        )
      )
    );
  }
}