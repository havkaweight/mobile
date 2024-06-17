import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/main.dart';
import 'package:havka/model/profile_data_model.dart';
import 'package:havka/model/user.dart';
import 'package:havka/routes/sharp_page_route.dart';
import 'package:havka/routes/transparent_page_route.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/screens/sign_in_screen.dart';
import 'package:havka/ui/screens/termination_screen.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/ui/widgets/rounded_button.dart';
import 'package:havka/ui/widgets/rounded_selector.dart';
import 'package:havka/ui/widgets/rounded_textfield.dart';
import 'package:havka/utils/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../components/date_of_birth_formatter.dart';
import '../../constants/gender.dart';
import '../../model/user_data_model.dart';
import '../../model/user_profile.dart';

class ProfileEditingScreen extends StatefulWidget {
  final User user;
  final UserProfile userProfile;

  const ProfileEditingScreen({
    required this.user,
    required this.userProfile,
  });

  @override
  _ProfileEditingScreenState createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen>
    with WidgetsBindingObserver {
  final ApiRoutes _apiRoutes = ApiRoutes();

  final ScrollController _profileScrollController = ScrollController();
  late Offset _appBarOffset;
  late double _appBarBlurRadius;

  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _firstNameTextController =
      TextEditingController();
  final TextEditingController _lastNameTextController = TextEditingController();
  final TextEditingController _dateOfBirthTextController = TextEditingController();
  final TextEditingController _heightTextController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _dateOfBirthFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  String formattedDate = '';

  late String? gender;

  late Widget doneButtonContent;

  @override
  void initState() {
    super.initState();
    final UserProfile? up = context.read<ProfileDataModel>().userProfile;

    doneButtonContent = Text(
      "Done",
      style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold),
    );

    _appBarOffset = Offset.zero;
    _appBarBlurRadius = 0.0;
    const _shift = 0.01;

    _profileScrollController.addListener(() {
      if (_profileScrollController.position.pixels / _profileScrollController.position.maxScrollExtent <= 0.0) {
        setState(() {
          _appBarOffset = Offset.zero;
          _appBarBlurRadius = 0.0;
        });
      } else if (_profileScrollController.position.pixels / _profileScrollController.position.maxScrollExtent > _shift) {
        setState(() {
          _appBarOffset = Offset(0.0, 2.0);
          _appBarBlurRadius = 1.0;
        });
      } else {
        setState(() {
          _appBarOffset = Offset(0.0, _profileScrollController.position.pixels / _profileScrollController.position.maxScrollExtent / (_shift * 2.0));
          _appBarBlurRadius = _profileScrollController.position.pixels / _profileScrollController.position.maxScrollExtent / _shift;
        });
      }
    });

    _firstNameTextController.text = up?.profileInfo.firstName ?? '';
    _lastNameTextController.text = up?.profileInfo.lastName ?? '';
    _dateOfBirthTextController.text = DateFormat("dd.MM.yyyy").format(up!.profileInfo.dateOfBirth!) ?? '';
    _heightTextController.text = up.bodyStats.height?.value == null ? '' : formattedNumber(double.parse(up.bodyStats.height!.value!.toString()));
    gender = widget.userProfile.profileInfo.gender;
  }

  @override
  void dispose() {
    _dateOfBirthTextController.dispose();
    _firstNameTextController.dispose();
    _lastNameTextController.dispose();
    _heightTextController.dispose();
    _profileScrollController.dispose();
    super.dispose();
  }

  Future _clearCache() async {
    final dir = await getTemporaryDirectory();
    dir.delete(recursive: true);
  }

  Future _showLogoutAlert() async {
    return showDialog(
      useRootNavigator: true,
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
                onPressed: _logout,
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
                onPressed: _logout,
              ),
          ],
          );
      },
    );
  }

  Future<void> _logout() async {
    await _clearCache();
    setState(() {
      removeToken();
      final googleSignIn = GoogleSignIn(scopes: ["email", "profile"]);
      googleSignIn.signOut();
      googleSignIn.disconnect();

      context.pop();
      context.go("/login");
    });
  }

  Future<void> _pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        final user = context.read<UserDataModel>();
        // user.user!.profilePhoto = returnedImage.path;
        user.updateData(user.user!);
      });
    }
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: HavkaColors.cream,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: _appBarOffset,
                      blurRadius: _appBarBlurRadius,
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                height: 60,
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
                        backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.black.withOpacity(0.05)),
                      ),
                    ),
                    TextButton(
                          onPressed: () async {
                            setState(() {
                              doneButtonContent = HavkaProgressIndicator();
                            });
                            final UserProfile updatedProfile = UserProfile.fromJson(widget.userProfile.toJson());
                            updatedProfile.profileInfo.firstName = _firstNameTextController.text;
                            updatedProfile.profileInfo.lastName = _lastNameTextController.text;
                            updatedProfile.profileInfo.gender = gender;
                            updatedProfile.profileInfo.dateOfBirth = DateFormat("dd.MM.yyyy").parse(_dateOfBirthTextController.text);
                            updatedProfile.bodyStats.height = _heightTextController.text.isEmpty ? null : Height(unit: "cm", value: double.parse(_heightTextController.text));
                            if (widget.userProfile != updatedProfile) {
                              final UserProfile up = await _apiRoutes.updateProfile(updatedProfile);
                              await context.read<ProfileDataModel>().updateProfile(up);
                            }
                            context.pop();
                          },
                          child: doneButtonContent,
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(
                                Colors.black.withOpacity(0.05)),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height
                    - MediaQuery.of(context).padding.top
                    - MediaQuery.of(context).padding.bottom
                    - MediaQuery.of(context).viewInsets.bottom
                    - 60,
                child: Scrollbar(
                  controller: _profileScrollController,
                  child: SingleChildScrollView(
                    controller: _profileScrollController,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: widget.userProfile.profileInfo.photo == null ||
                                    !File(widget.userProfile.profileInfo.photo!).existsSync()
                                ? InkWell(
                                    onTap: () async {
                                      _pickImage();
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.05),
                                          border: Border.all(
                                              width: 4,
                                              color: Colors.black.withOpacity(0.05)),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        height: MediaQuery.of(context).size.width * 0.3,
                                        child: Center(
                                            child: FaIcon(
                                          FontAwesomeIcons.user,
                                          color: Colors.black.withOpacity(0.2),
                                          size: 60,
                                        ))),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      File(widget.userProfile.profileInfo.photo!),
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      height: MediaQuery.of(context).size.width * 0.3,
                                    ),
                                  ),
                          ),
                          TextButton(
                            onPressed: () async {
                              _pickImage();
                            },
                            child: Text(
                              "Set photo",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal),
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll<Color>(
                                  Colors.black.withOpacity(0.05)),
                            ),
                          ),
                          Consumer<UserDataModel>(
                            builder: (context, user, _) {
                              _usernameTextController.text = user.user!.username;
                              return RoundedTextField(
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.at,
                                  size: 18,
                                ),
                                textCapitalization: TextCapitalization.none,
                                hintText: "Username",
                                controller: _usernameTextController,
                                focusNode: _usernameFocusNode,
                                enabled: false,
                                button: TextButton(
                                  onPressed: () => context.push("/profile/edit/username", extra: user.user!),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.05)),
                                  ),
                                  child: Text(
                                    "Change",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                          RoundedTextField(
                            hintText: "First Name",
                            controller: _firstNameTextController,
                            focusNode: _firstNameFocusNode,
                          ),
                          RoundedTextField(
                            hintText: "Last Name",
                            controller: _lastNameTextController,
                            focusNode: _lastNameFocusNode,
                          ),
                          RoundedSelector(
                            items: Gender.list().map((e) => e.name).toList(),
                            initialItem: gender == null ? null : Gender.getBySlug(gender!).name,
                            onSelectedItem: (item) {
                              gender = Gender.getByName(item).slug;
                            },
                          ),
                          RoundedTextField(
                            hintText: "Date of birth",
                            controller: _dateOfBirthTextController,
                            focusNode: _dateOfBirthFocusNode,
                            enableClearButton: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              DateOfBirthFormatter(),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            iconButton: IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              onPressed: () async {
                                final String? dob = await _buildDateOfBirthModal(_dateOfBirthTextController.text);
                                if (dob != null) {
                                  _dateOfBirthTextController.text = dob;
                                }
                              },
                            ),
                            descriptionText: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(text: "Type using pattern "),
                                  TextSpan(
                                    text: "dd.mm.yyyy",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: " or use the date picker"),
                                ]
                              ),
                            ),
                          ),
                          RoundedTextField(
                            hintText: "Height",
                            controller: _heightTextController,
                            focusNode: _heightFocusNode,
                            keyboardType: TextInputType.number,
                            trailingText: "cm",
                          ),
                          SizedBox(height: 60,),
                          Column(
                            children: [
                              InkWell(
                                onTapUp: (_) {
                                  _showLogoutAlert();
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    color: HavkaColors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Log out",
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTapUp: (_) => context.push(
                                "/profile/edit/terminate",
                                extra: widget.user,
                              ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    color: HavkaColors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Terminate my account",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _buildDateOfBirthModal(String dobString) async {
    final DateTime? parsedDate = DateFormat("dd.MM.yyyy").tryParse(dobString);
    DateTime? selectedDate = (parsedDate != null && parsedDate.isAfter(DateTime.now().subtract(Duration(days: 365*100)))) ? parsedDate : DateTime.now().subtract(Duration(days: 365*20));
    double maxChildSize = 0.3;
    return await showModalBottomSheet(
      useRootNavigator: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AnimatedSize(
            duration: Duration(milliseconds: 200),
            child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: maxChildSize,
                minChildSize: 0,
                maxChildSize: maxChildSize,
                builder: (context, scrollController) {
                  return ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    child: SafeArea(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    child: Text("Cancel"),
                                    onPressed: () => context.pop(),
                                  ),
                                  TextButton(
                                    child: Text("Done"),
                                    onPressed: () {
                                      context.pop(DateFormat("dd.MM.yyyy").format(selectedDate!));
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height:
                              MediaQuery.of(context).size.height *
                                  0.3 -
                                  MediaQuery.of(context)
                                      .padding
                                      .bottom -
                                  50,
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.date,
                                dateOrder: DatePickerDateOrder.dmy,
                                initialDateTime: selectedDate,
                                minimumDate: DateTime.now()
                                    .subtract(Duration(days: 365*100)),
                                maximumDate: DateTime.now(),
                                onDateTimeChanged: (value) {
                                  selectedDate = value;
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          );
        });
      },
    );
  }
}
