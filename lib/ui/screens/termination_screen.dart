import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/main.dart';
import 'package:havka/model/user.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';


class TerminationScreen extends StatefulWidget {
  final User user;

  const TerminationScreen({
    required this.user,
  });

  @override
  _TerminationScreenState createState() => _TerminationScreenState();
}

class _TerminationScreenState extends State<TerminationScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  late final TextEditingController _emailController;

  bool isEmailMatch = false;
  double isTextFieldHidden = 0.3;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _emailController.addListener(emailMatchCheck);
  }

  void emailMatchCheck() {
    isEmailMatch = _emailController.text == widget.user.email;
    setState(() {
      isTextFieldHidden = isEmailMatch ? 1.0 : 0.3;
    });
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
        backgroundColor: Colors.red.withOpacity(0.7),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 30.0),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 20.0),
                                child: Icon(
                                  FontAwesomeIcons.fire,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                child: Text(
                                  "DANGER ZONE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            "You are going to terminate your account in Havka. It means your data will be permanently deleted, you will not be able to restore it. But after the termination we will keep your account alive for 6 months so you have 6 months to change your decision and return to us. After that your account will be permanently deleted.",
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            "If you still want to terminate you account, please type your email below and click on Terminate button",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        RoundedTextField(
                          hintText: "Email",
                          controller: _emailController,
                          fillColor: Colors.white.withOpacity(0.9),
                          textCapitalization: TextCapitalization.none,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: AlignmentDirectional.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => context.pop(),
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.white.withOpacity(0.2))
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 300),
                          opacity: isTextFieldHidden,
                          child: TextButton(
                            onPressed: () async {
                              if (!isEmailMatch) {
                                return ;
                              }
                              await _apiRoutes.deleteMe();
                              removeToken();
                              final googleSignIn = GoogleSignIn(scopes: ["email", "profile"]);
                              googleSignIn.signOut();
                              googleSignIn.disconnect();
                              context.go("/login");
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(Colors.white.withOpacity(0.2))
                            ),
                            child: Text(
                              "Terminate",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
        ),
      ),
    );
  }
}
