import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/presentation/providers/fridge_provider.dart';
import 'package:havka/presentation/widgets/blurred_overlay.dart';
import 'package:havka/presentation/widgets/progress_indicator.dart';
import 'package:havka/presentation/widgets/submit_button.dart';
import '../../domain/entities/fridge/fridge.dart';
import '/core/constants/colors.dart';
import '/domain/entities/fridge/user_fridge.dart';
import '/presentation/widgets/rounded_button.dart';
import '/presentation/widgets/rounded_textfield.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class FridgeAdjustmentScreen extends StatefulWidget {
  final UserFridge? userFridge;

  const FridgeAdjustmentScreen({
    this.userFridge,
  });

  @override
  _FridgeAdjustmentScreenState createState() => _FridgeAdjustmentScreenState();
}

class _FridgeAdjustmentScreenState extends State<FridgeAdjustmentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fridgeIdController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode fridgeIdFocusNode = FocusNode();
  String buttonText = "Copy Fridge ID";

  late ScrollController _scrollController;
  GlobalKey backgroundWidgetKey = GlobalKey();
  late Offset widgetOffset;
  late double _currentPosition;
  double opacity = 1;

  static final List<Widget> iconsList = List.generate(
    100,
    (_) {
      return Icon(
        Icons.kitchen,
        color: Colors.grey.withValues(alpha: 0.3),
        size: 30,
      );
    },
  );

  @override
  void initState() {
    super.initState();

    if (widget.userFridge != null) {
      nameController.text = widget.userFridge!.name;
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollBehaviour);
  }

  _scrollBehaviour() {
    RenderBox renderBox =
        backgroundWidgetKey.currentContext?.findRenderObject() as RenderBox;
    widgetOffset = renderBox.localToGlobal(Offset.zero);
    _currentPosition = widgetOffset.dy;

    if (_currentPosition < 0 && _currentPosition >= -100) {
      setState(() {
        opacity = 1 - _currentPosition.abs() / 100;
      });
    } else if (_currentPosition >= 0 && opacity != 1) {
      setState(() {
        opacity = 1;
      });
    } else if (_currentPosition < -100 && opacity != 0) {
      setState(() {
        opacity = 0;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fridgeProvider = context.read<FridgeProvider>();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: PhysicalModel(
          color: HavkaColors.cream,
          elevation: 20,
          child: Stack(
            children: [
              AnimatedOpacity(
                opacity: opacity,
                duration: Duration.zero,
                child: Container(
                  alignment: AlignmentDirectional.topCenter,
                  height: screenHeight,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0, 0.25],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    // child: Wrap(
                    //   spacing: 30,
                    //   runSpacing: 30,
                    //   children: iconsList,
                    // ),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Stack(
                        children: [
                          Container(
                            height: screenHeight,
                            child: GridView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (MediaQuery.of(context).size.width / 50)
                                        .ceil(),
                              ),
                              itemBuilder: (context, index) {
                                return Center(
                                  child: Icon(
                                    Icons.kitchen,
                                    size: 40,
                                    color: Colors.grey.withValues(alpha: 0.3),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            height: screenHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white.withValues(alpha: 0),
                                ],
                                stops: [0.0, 0.25],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                key: backgroundWidgetKey,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 30.0),
                            child: Icon(
                              widget.userFridge == null
                                  ? CupertinoIcons.add_circled
                                  : CupertinoIcons.pencil_circle,
                              color: HavkaColors.green,
                              size: 70,
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                child: Column(
                                  children: [
                                    RoundedTextField(
                                      hintText: 'Name',
                                      controller: nameController,
                                      focusNode: nameFocusNode,
                                      onSubmitted: (_) =>
                                          fridgeIdFocusNode.requestFocus(),
                                    ),
                                    widget.userFridge == null
                                        ? RoundedTextField(
                                            hintText: 'Fridge ID (optional)',
                                            controller: fridgeIdController,
                                            focusNode: fridgeIdFocusNode,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            onSubmitted: (_) =>
                                                fridgeIdFocusNode.unfocus(),
                                            descriptionText: Text(
                                              'Paste here the Fridge ID that your friend has shared with you',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              ),
                              widget.userFridge != null
                                  ? Column(
                                      children: [
                                        RoundedButton(
                                            width: 300,
                                            text: buttonText,
                                            onPressed: () async {
                                              await Clipboard.setData(
                                                  ClipboardData(
                                                      text: widget.userFridge!
                                                          .fridgeId));
                                              HapticFeedback.lightImpact();
                                              setState(() {
                                                buttonText = 'Copied!';
                                                Future.delayed(
                                                    Duration(seconds: 2),
                                                    () => setState(() {
                                                          buttonText =
                                                              'Copy Fridge ID';
                                                        }));
                                              });
                                            }),
                                        RoundedButton(
                                            width: 300,
                                            text: 'Share',
                                            onPressed: () async {
                                              Share.share(
                                                'Use my Fridge in Havka by Fridge ID:\n\n${widget.userFridge!.fridgeId}',
                                                subject:
                                                    'Fridge ID: ${widget.userFridge!.fridgeId}',
                                              );
                                            }),
                                      ],
                                    )
                                  : SizedBox.shrink(),
                              SubmitButton(
                                text:
                                    widget.userFridge == null ? 'Add' : 'Save',
                                onSubmit: () async {
                                  if (widget.userFridge == null) {
                                    final fridgeName = nameController.text;
                                    final fridgeId =
                                        fridgeIdController.text.isNotEmpty
                                            ? fridgeIdController.text
                                            : null;
                                    await fridgeProvider.createUserFridge(
                                        fridgeName,
                                        fridgeId: fridgeId);
                                  } else {
                                    final updatedUserFridge = UserFridge(
                                        id: widget.userFridge!.id,
                                        name: nameController.text,
                                        fridgeId: widget.userFridge!.fridgeId);
                                    await fridgeProvider
                                        .updateUserFridge(updatedUserFridge);
                                  }
                                  context.pop();
                                },
                                disabled: false,
                              ),
                            ],
                          ),
                        ],
                      ),
                      widget.userFridge == null
                          ? SizedBox.shrink()
                          : fridgeProvider.userFridges.length > 1
                              ? TextButton(
                                  onPressed: () =>
                                      _showDeletingAlert(context, () async {
                                    OverlayEntry overlayEntry = OverlayEntry(
                                        builder: (context) => BlurredOverlay());
                                    Navigator.of(context)
                                        .overlay!
                                        .insert(overlayEntry);
                                    await fridgeProvider
                                        .deleteUserFridge(widget.userFridge!);
                                    await fridgeProvider.deleteFridge(
                                        widget.userFridge!.fridgeId);
                                    Future.delayed(Duration(seconds: 1), () {
                                      overlayEntry.remove();
                                      context.pop();
                                    });
                                  }),
                                  child: Text(
                                    "Delete this fridge",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 16),
                                  ),
                                )
                              : Text(
                                  "You cannot delete this fridge because you have only one",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _showDeletingAlert(context, VoidCallback onDelete) async {
    return showDialog(
      context: context,
      builder: (context) {
        return Platform.isIOS
            ? CupertinoAlertDialog(
                title: Text("Are you sure?"),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      context.pop();
                      onDelete();
                    },
                  ),
                ],
              )
            : AlertDialog(
                title: Text("Are you sure?"),
                actions: [
                  TextButton(
                    child: Text(
                      "No",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () => context.pop(),
                  ),
                  TextButton(
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () async {
                      context.pop();
                      onDelete();
                    },
                  ),
                ],
              );
      },
    );
  }
}
