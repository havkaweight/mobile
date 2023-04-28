import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:health_tracker/api/methods.dart';
import 'package:health_tracker/model/user.dart';
import 'package:health_tracker/ui/widgets/rounded_button.dart';
import 'package:health_tracker/ui/widgets/rounded_textfield.dart';

class ProfileEditingScreen extends StatefulWidget {
  final User user;
  const ProfileEditingScreen({required this.user});

  @override
  _ProfileEditingScreenState createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final ApiRoutes _apiRoutes = ApiRoutes();

  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _firstNameTextController =
      TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _heightTextController = TextEditingController();
  final TextEditingController _weightTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameTextController.text = widget.user.username!;
    _firstNameTextController.text = widget.user.profileInfo!.firstName ?? '';
    _lastNameTextController.text = widget.user.profileInfo!.lastName ?? '';
    _heightTextController.text =
        widget.user.bodyStats!.height?.value.toString() ?? '';
    _weightTextController.text =
        widget.user.bodyStats!.weight?.value.toString() ?? '';
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  RoundedTextField(
                    hintText: 'Username',
                    controller: _usernameTextController,
                  ),
                  RoundedTextField(
                    hintText: 'First Name',
                    controller: _firstNameTextController,
                  ),
                  RoundedTextField(
                    hintText: 'Last Name',
                    controller: _lastNameTextController,
                  ),
                  RoundedTextField(
                    prefixIcon: const Icon(
                      FontAwesomeIcons.rulerVertical,
                      size: 20,
                    ),
                    suffixText: 'cm',
                    hintText: 'Height',
                    controller: _heightTextController,
                  ),
                  RoundedTextField(
                    prefixIcon: const Icon(
                      FontAwesomeIcons.weightScale,
                      size: 20,
                    ),
                    suffixText: 'kg',
                    hintText: 'Weight',
                    controller: _weightTextController,
                  ),
                ],
              ),
              RoundedButton(
                text: 'Save',
                onPressed: () {
                  final User updatedUser = User(
                    username: _usernameTextController.text,
                    profileInfo: ProfileInfo(
                      firstName: _firstNameTextController.text,
                      lastName: _lastNameTextController.text,
                    ),
                    bodyStats: BodyStats(
                      height: Height(
                        unit: 'cm',
                        value: double.parse(
                          _heightTextController.text,
                        ),
                      ),
                      weight: Weight(
                        unit: 'kg',
                        value: double.parse(
                          _weightTextController.text,
                        ),
                      ),
                    ),
                  );
                  _apiRoutes.updateMe(updatedUser);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
