import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/constants/colors.dart';

class RoundedTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final Color? color;
  final Color? fillColor;
  final Icon? prefixIcon;
  final IconButton? iconButton;
  final String? suffixText;
  final List<String>? dropDownItemsList;
  final String? dropDownInitialValue;
  final Widget? descriptionText;
  final bool obscureText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool? autoFocus;
  final String? errorText;
  final TextEditingController? controller;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onSubmitted;
  final Function(String)? onSelectedDropDownItem;
  final Function()? onTap;
  final TextAlign? textAlign;
  final bool enableClearButton;
  final bool enabled;
  final TextButton? button;
  final String? fillingHintText;
  final int? maxLines;
  final bool expands;
  final String? trailingText;

  RoundedTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixText,
    this.dropDownItemsList,
    this.dropDownInitialValue,
    this.descriptionText,
    this.iconButton,
    this.color,
    this.fillColor = const Color(0x0D000000),
    this.controller,
    this.textCapitalization = TextCapitalization.words,
    this.focusNode,
    this.textInputAction,
    this.errorText,
    this.obscureText = false,
    this.autoFocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onSubmitted,
    this.onSelectedDropDownItem,
    this.onTap,
    this.textAlign = TextAlign.start,
    this.enableClearButton = true,
    this.enabled = true,
    this.button,
    this.fillingHintText,
    this.maxLines = 1,
    this.expands = false,
    this.trailingText,
  });

  @override
  RoundedTextFieldState createState() => RoundedTextFieldState();
}

class RoundedTextFieldState<T extends RoundedTextField>
    extends State<RoundedTextField> with SingleTickerProviderStateMixin {

  late String? dropDownSelectedValue;
  late bool _isIconShown;
  late bool obscureText;
  late double dropdownButtonWidth;

  @override
  void initState() {
    super.initState();
    obscureText = widget.obscureText;
    _isIconShown = false;
    if (widget.dropDownItemsList != null) {
      dropDownSelectedValue = widget.dropDownInitialValue ?? widget.dropDownItemsList?.first;
      dropdownButtonWidth = _calculateDropdownButtonWidth(dropDownSelectedValue!);
    }
    if (widget.obscureText) {
      widget.controller?.addListener(_showEyeIcon);
    }
  }

  _onFocusChanged() {
    setState(() {});
  }

  _showEyeIcon() {
    if (widget.controller!.text.isEmpty) {
      _isIconShown = false;
    } else {
      _isIconShown = true;
    }
  }

  void _togglePasswordView() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  double _calculateDropdownButtonWidth(String item) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: item,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 10.0,
              bottom: widget.descriptionText == null ? 10.0 : 0.0,
            ),
            decoration: BoxDecoration(
              color: widget.fillColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      TextField(
                        expands: widget.expands,
                        maxLines: widget.maxLines,
                        textAlign: widget.textAlign!,
                        focusNode: widget.focusNode,
                        textInputAction: widget.textInputAction,
                        obscureText: obscureText,
                        keyboardType: widget.keyboardType,
                        inputFormatters: widget.inputFormatters,
                        autofocus: widget.autoFocus!,
                        controller: widget.controller,
                        textCapitalization: widget.textCapitalization,
                        autocorrect: false,
                        enableSuggestions: false,
                        enabled: widget.enabled,
                        onSubmitted: widget.onSubmitted,
                        onChanged: (_) {
                          setState(() {});
                        },
                        onTap: widget.onTap,
                        decoration: InputDecoration(
                          counterStyle: TextStyle(
                            color: Color(0x7A66550B),
                            // fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.only(
                            top: 0.0,
                            bottom: 0.0,
                            left: 20.0,
                            right:
                                widget.dropDownItemsList == null ? 20.0 : 10.0,
                          ),
                          prefixIcon: widget.prefixIcon,
                          suffixIcon: widget.iconButton,
                          suffixText: widget.suffixText,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusColor: Color(0xFFFFFFFF),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFF0000), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          fillColor: Colors.transparent,
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFFF0000), width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          hintText: widget.hintText,
                          errorText: widget.errorText,
                          hintStyle: TextStyle(
                            color: Color(0x7A66550B),
                            // fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      widget.fillingHintText == null
                          ? SizedBox.shrink()
                          : Container(
                              margin: EdgeInsets.only(
                                top: 0.0,
                                bottom: 0.0,
                                left: 20.0,
                                right: widget.dropDownItemsList == null
                                    ? 20.0
                                    : 10.0,
                              ),
                              child: Text(
                                "dd.mm.yyyy",
                                style: TextStyle(
                                  color: Color(0x7A66550B),
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                Builder(builder: (context) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    transitionBuilder: (child, controller) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0.5, 0.0),
                          end: Offset.zero,
                        ).animate(controller),
                        child: FadeTransition(
                          opacity: controller,
                          child: child,
                        ),
                      );
                    },
                    child: widget.enableClearButton &&
                            widget.focusNode != null &&
                            widget.focusNode!.hasFocus &&
                            widget.controller!.text.isNotEmpty
                        ? Container(
                            height: 20,
                            width: 20,
                            margin: EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: IconButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.black.withOpacity(0.05))),
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.withOpacity(0.8),
                                size: 14,
                              ),
                              onPressed: () {
                                setState(() {
                                  widget.controller?.clear();
                                });
                              },
                            ),
                          )
                        : SizedBox.shrink(),
                  );
                }),
                Builder(builder: (context) {
                  return AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    transitionBuilder: (child, controller) {
                      return FadeTransition(
                        opacity: controller,
                        child: child,
                      );
                    },
                    child: _isIconShown
                        ? IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            onPressed: _togglePasswordView,
                          )
                        : SizedBox.shrink(),
                  );
                }),
                Builder(builder: (context) {
                  return Row(
                    children: [
                      widget.trailingText == null
                          ? SizedBox.shrink()
                          : Container(
                              margin: EdgeInsets.only(
                                left: 8.0,
                                right: widget.dropDownItemsList == null ? 20.0 : 8.0,
                              ),
                              child: Text(
                                widget.trailingText!,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                      widget.dropDownItemsList == null
                      ? SizedBox.shrink()
                      : Container(
                        alignment: AlignmentDirectional.center,
                        height: 32,
                        width: dropdownButtonWidth + 25.0,
                        margin: EdgeInsets.only(
                          right: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: DropdownButton(
                          isExpanded: true,
                          alignment: AlignmentDirectional.center,
                          underline: Container(),
                          icon: Visibility(
                              visible: false,
                              child: Icon(Icons.arrow_downward)),
                          borderRadius: BorderRadius.circular(10.0),
                          value: dropDownSelectedValue,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.3),
                            // fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          items: widget.dropDownItemsList!
                              .map((item) => DropdownMenuItem(
                                    alignment: AlignmentDirectional.center,
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              dropDownSelectedValue = value;
                              dropdownButtonWidth =
                                  _calculateDropdownButtonWidth(dropDownSelectedValue!);
                            });
                            if (widget.onSelectedDropDownItem != null) {
                              widget.onSelectedDropDownItem!(value!);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }),
                widget.button == null
                    ? SizedBox.shrink()
                    : Container(
                        height: 35,
                        margin: EdgeInsets.only(right: 10.0),
                        child: widget.button!,
                      ),
              ],
            ),
          ),
          widget.descriptionText == null
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(
                      top: 5.0,
                      left: 15.0,
                      right: 15.0,
                      bottom: widget.descriptionText == null ? 0.0 : 10.0),
                  alignment: AlignmentDirectional.topStart,
                  child: widget.descriptionText!,
                ),
        ],
      ),
    );
  }
}
