import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:havka/presentation/widgets/progress_indicator.dart';

class SubmitButton extends StatefulWidget {
  final String text;
  final Future<void> Function()? onSubmit;
  final bool? disabled;

  SubmitButton({
    required this.text,
    required this.onSubmit,
    this.disabled = false,
  });

  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  late Widget buttonContent;
  bool _isLoading = false;

  final textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );

  @override
  void initState() {
    super.initState();
    buttonContent = Text(
      widget.text,
      style: textStyle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (_isLoading || (widget.disabled ?? false))
          ? null
          : () async {
        setState(() {
          _isLoading = true;
          buttonContent = HavkaProgressIndicator();
        });try {
          if (widget.onSubmit != null) {
            await widget.onSubmit!();
          }
        } catch (e) {
          print('Something went wrong: $e');
        } finally {
          setState(() {
            _isLoading = false;
            buttonContent = Text(
              widget.text,
              style: textStyle,
            );
          });
        }
      },
      child: AnimatedSize(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 100),
          child: Container(
            key: ValueKey(_isLoading || (widget.disabled ?? false)),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: widget.disabled! ? 0.01 : 0.05),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
                width: 1.0,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: buttonContent
          ),
        ),
      ),
    );
  }
}