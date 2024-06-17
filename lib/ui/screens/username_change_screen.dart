import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/main.dart';
import 'package:havka/model/user.dart';
import 'package:havka/routes/sharp_page_route.dart';
import 'package:havka/routes/transparent_page_route.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/screens/sign_in_screen.dart';
import 'package:havka/ui/screens/termination_screen.dart';
import 'package:havka/ui/widgets/rounded_button.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../model/user_data_model.dart';
import '../widgets/progress_indicator.dart';

class UsernameChangeScreen extends StatefulWidget {
  final User user;

  const UsernameChangeScreen({
    required this.user,
  });

  @override
  _UsernameChangeScreenScreenState createState() => _UsernameChangeScreenScreenState();
}

class _UsernameChangeScreenScreenState extends State<UsernameChangeScreen> {
  final TextEditingController _usernameTextController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();

  late Widget doneButtonContent;


  @override
  void initState() {
    super.initState();
    _usernameTextController.text = widget.user.username;
    _usernameFocusNode.requestFocus();

    doneButtonContent = Text(
      "Done",
      style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.black.withOpacity(0.05)),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                doneButtonContent = HavkaProgressIndicator();
                              });
                              if(widget.user.username != _usernameTextController.text) {
                                widget.user.username = _usernameTextController.text;
                                final User user = await ApiRoutes().updateUsername(widget.user);
                                await context.read<UserDataModel>().updateData(user);
                              }
                              context.pop();
                            },
                            child: doneButtonContent,
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                  Colors.black.withOpacity(0.05)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          RoundedTextField(
                            prefixIcon: const Icon(
                              FontAwesomeIcons.at,
                              size: 18,
                            ),
                            enableClearButton: true,
                            textCapitalization: TextCapitalization.none,
                            hintText: "Username",
                            controller: _usernameTextController,
                            focusNode: _usernameFocusNode,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
