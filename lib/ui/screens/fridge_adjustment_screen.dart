import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/model/fridge.dart';
import 'package:havka/model/fridge_data_model.dart';
import 'package:havka/ui/widgets/rounded_button.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';
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
  final ApiRoutes _apiRoutes = ApiRoutes();
  String buttonText = "Copy Fridge ID";

  late ScrollController _scrollController;
  GlobalKey backgroundWidgetKey = GlobalKey();
  late Offset widgetOffset;
  late double _currentPosition;
  double opacity = 1;

  late final FridgeDataModel fridgeData;

  static final List<Widget> iconsList = List.generate(
    100,
    (_) {
      return Icon(
        Icons.kitchen,
        color: Colors.grey.withOpacity(0.3),
        size: 30,
      );
    },
  );

  @override
  void initState() {
    super.initState();

    fridgeData = context.read<FridgeDataModel>();
    nameController.text = widget.userFridge?.name ?? "";

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
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.background,
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
                  height: double.infinity,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0, 0.25],
                      ).createShader(
                        Rect.fromLTRB(
                          0,
                          0,
                          rect.width,
                          rect.height,
                        ),
                      );
                    },
                    blendMode: BlendMode.dstIn,
                    child: Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      children: iconsList,
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
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 30.0),
                            child: Column(
                              children: [
                                Icon(
                                  widget.userFridge == null
                                      ? CupertinoIcons.add_circled
                                      : CupertinoIcons.pencil_circle,
                                  color: HavkaColors.green,
                                  size: 90,
                                ),
                              ],
                            ),
                          ),
                          RoundedTextField(
                            hintText: "Name",
                            controller: nameController,
                            focusNode: nameFocusNode,
                            onSubmitted: (_) =>
                                fridgeIdFocusNode.requestFocus(),
                          ),
                          widget.userFridge == null
                              ? Column(
                                  children: [
                                    RoundedTextField(
                                      hintText: "Fridge ID",
                                      controller: fridgeIdController,
                                      focusNode: fridgeIdFocusNode,
                                      textCapitalization:
                                          TextCapitalization.none,
                                      onSubmitted: (_) =>
                                          fridgeIdFocusNode.unfocus(),
                                      descriptionText: Text(
                                        "Paste here the Fridge ID that your friend has shared with you",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    RoundedButton(
                                        width: 300,
                                        text: buttonText,
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text:
                                                  widget.userFridge!.fridgeId));
                                          HapticFeedback.lightImpact();
                                          setState(() {
                                            buttonText = "Copied!";
                                            Future.delayed(
                                                Duration(seconds: 2),
                                                () => setState(() {
                                                      buttonText =
                                                          "Copy Fridge ID";
                                                    }));
                                          });
                                        }),
                                    RoundedButton(
                                        width: 300,
                                        text: "Share",
                                        onPressed: () async {
                                          Share.share(
                                            "Use my Fridge in Havka by Fridge ID:\n\n${widget.userFridge!.fridgeId}",
                                            subject:
                                                "Fridge ID: ${widget.userFridge!.fridgeId}",
                                          );
                                        }),
                                  ],
                                ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 40.0),
                            child: RoundedButton(
                              text: widget.userFridge == null ? "Add" : "Done",
                              onPressed: () async {
                                late final UserFridge? uf;
                                if (widget.userFridge == null) {
                                  uf = await _createUserFridge();
                                } else {
                                  widget.userFridge!.name = nameController.text;
                                  uf = await _modifyUserFridge(widget.userFridge!);
                                }
                                context.pop(uf);
                              },
                            ),
                          ),
                        ],
                      ),
                      widget.userFridge == null
                          ? SizedBox.shrink()
                          : fridgeData.fridgeData.length > 1
                              ? TextButton(
                                  onPressed: _showDeletingAlert,
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

  Future<UserFridge?> _createUserFridge() async {
    final String fridgeName = nameController.text;
    if (fridgeIdController.text.isEmpty) {
      final Fridge? fridge = await _apiRoutes.createFridge();
      if (fridge != null) {
        final UserFridge uf =
            UserFridge(name: fridgeName, fridgeId: fridge.id!);
        return await _apiRoutes.createUserFridge(userFridge: uf);
      }
    } else {
      final UserFridge uf =
          UserFridge(name: fridgeName, fridgeId: fridgeIdController.text);
      return await _apiRoutes.createUserFridge(userFridge: uf);
    }
    return null;
  }

  Future<UserFridge?> _modifyUserFridge(UserFridge uf) async {
    context.read<FridgeDataModel>().modifyUserFridge(uf);
    return uf;
  }

  Future<bool> _deleteUserFridge(UserFridge uf) async {
    final bool isDeleted = await _apiRoutes.deleteUserFridge(userFridge: uf);
    return isDeleted;
  }

  Future<void> _deleteFridge(UserFridge uf) async {
    await _apiRoutes.deleteFridge(userFridge: uf);
  }

  Future _showDeletingAlert() async {
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
                      final bool isDeleted =
                          await _deleteUserFridge(widget.userFridge!);
                      widget.userFridge!.isDeleted = isDeleted;
                      await _deleteFridge(widget.userFridge!);
                      context.pop();
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
                      final bool isDeleted =
                          await _deleteUserFridge(widget.userFridge!);
                      widget.userFridge!.isDeleted = isDeleted;
                      await _deleteFridge(widget.userFridge!);
                      context.pop();
                    },
                  ),
                ],
              );
      },
    );
  }
}
