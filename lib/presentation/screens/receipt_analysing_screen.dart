import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '/core/constants/colors.dart';

class ReceiptAnalysingScreen extends StatefulWidget {
  final String imagePath;

  const ReceiptAnalysingScreen({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  _ReceiptAnalysingScreenState createState() => _ReceiptAnalysingScreenState();
}

class _ReceiptAnalysingScreenState extends State<ReceiptAnalysingScreen>
    with SingleTickerProviderStateMixin {
  late Widget productsWidget;

  late AnimationController _receiptAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _receiptAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _receiptAnimationController, curve: Curves.decelerate));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _receiptAnimationController, curve: Curves.decelerate));

    productsWidget = Container();
  }

  @override
  void dispose() {
    _receiptAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Hero(
                      tag: "receiptCameraImage",
                      child: Image.file(File(widget.imagePath)),
                    ),
                    productsWidget,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Colors.black.withValues(alpha: 0.1)),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: Text(
                        "Analyze",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Colors.black.withValues(alpha: 0.1)),
                      ),
                      onPressed: () async {
                        productsWidget = await analyzePhoto();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        )),
      ),
    );
  }

  Future<Widget> analyzePhoto() async {
    final inputImage = InputImage.fromFilePath(widget.imagePath);
    final textRecognizer = TextRecognizer();
    final results = await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    if (results.text.isEmpty) {
      return Container();
    }
    final recognizedText = results.text;
    final barcodesRegexp = RegExp(r'[0-9]{12,13}');
    if (!barcodesRegexp.hasMatch(recognizedText)) {
      return Container();
    }
    final List barcodeList = barcodesRegexp
        .allMatches(recognizedText)
        .map((e) => e.group(0))
        .toList();
    setState(() {
      _receiptAnimationController.forward();
    });
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          child: PhysicalModel(
            borderRadius: BorderRadius.circular(10.0),
            color: HavkaColors.cream.withValues(alpha: 0.95),
            elevation: 20,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      "Food from your receipt:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    child: ShaderMask(
                      shaderCallback: (Rect rect) {
                        return LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.7, 1],
                        ).createShader(
                          Rect.fromLTRB(
                            0,
                            0,
                            rect.width,
                            rect.height,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(barcodeList.length, (index) {
                            return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 10.0),
                                          child: Icon(FontAwesomeIcons.barcode),
                                        ),
                                        Text(barcodeList[index]),
                                      ],
                                    ),
                                    Checkbox(
                                      value: true,
                                      onChanged: (value) => !value!,
                                    )
                                  ],
                                ));
                          }),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.1))
                      ),
                      onPressed: () {},
                      child: Text(
                        "Add selected food",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
