import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:havka/presentation/providers/profile_provider.dart';
import 'package:havka/presentation/providers/user_provider.dart';
import 'package:havka/presentation/widgets/submit_button.dart';
import '../../domain/entities/profile/body_stats.dart';
import '../../domain/entities/profile/height.dart';
import '../../domain/entities/profile/profile.dart';
import '../../domain/entities/profile/profile_info.dart';
import '../../utils/format_number.dart';
import '../providers/auth_provider.dart';
import '/core/constants/colors.dart';
import '../../domain/entities/user/user.dart';
import '/presentation/screens/authorization.dart';
import '/presentation/widgets/progress_indicator.dart';
import '/presentation/widgets/rounded_selector.dart';
import '/presentation/widgets/rounded_textfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '/utils/formatters/date_of_birth_formatter.dart';
import '/core/constants/gender.dart';

class ProfileEditingScreen extends StatefulWidget {
  final User user;
  final Profile profile;

  const ProfileEditingScreen({
    required this.user,
    required this.profile,
  });

  @override
  _ProfileEditingScreenState createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen>
    with WidgetsBindingObserver {
  // final ApiRoutes _apiRoutes = ApiRoutes();

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
    final UserProvider userProvider = context.read<UserProvider>();
    final ProfileProvider profileProvider = context.read<ProfileProvider>();

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

    _firstNameTextController.text = profileProvider.profile!.profileInfo!.firstName ?? '';
    _lastNameTextController.text = profileProvider.profile!.profileInfo!.lastName ?? '';
    _dateOfBirthTextController.text = DateFormat("dd.MM.yyyy").format(profileProvider.profile!.profileInfo!.dateOfBirth!);
    _heightTextController.text = profileProvider.profile!.bodyStats!.height!.value == null ? '' : formatNumber(double.parse(profileProvider.profile!.bodyStats!.height!.value.toString()));
    gender = profileProvider.profile!.profileInfo!.gender;
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
    final AuthProvider authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    context.pop();
    context.go('/login');
  }

  Future<void> _pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage != null) {
      setState(() {
        final userProvider = context.read<UserProvider>();
        // user.user!.profilePhoto = returnedImage.path;
        userProvider.updateUser(userProvider.user!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context);
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
                      color: Colors.black.withValues(alpha: 0.05),
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
                    SubmitButton(
                      text: 'Back',
                      onSubmit: () async => context.pop(),
                    ),
                    SubmitButton(
                      text: 'Done',
                      onSubmit: () async {
                        final Profile updatedProfile = Profile(
                            id: widget.profile.id,
                            userId: widget.user.id,
                            firstName: _firstNameTextController.text,
                            lastName: _lastNameTextController.text,
                            profileInfo: ProfileInfo(
                              firstName: _firstNameTextController.text,
                              lastName: _lastNameTextController.text,
                              dateOfBirth: DateFormat("dd.MM.yyyy").parse(_dateOfBirthTextController.text),
                              gender: gender,
                            ),
                            bodyStats: BodyStats(
                              height: _heightTextController.text.isEmpty ? null : Height(unit: "cm", value: double.parse(_heightTextController.text)),
                              weight: widget.profile.bodyStats!.weight,
                            )
                        );
                        await profileProvider.updateProfile(updatedProfile);
                        context.pop();
                      },
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
                            child: profileProvider.profile!.profileInfo!.photo == null ||
                                    !File(profileProvider.profile!.profileInfo!.photo!).existsSync()
                                ? InkWell(
                                    onTap: () async {
                                      _pickImage();
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          border: Border.all(
                                              width: 4,
                                              color: Colors.black.withValues(alpha: 0.05)),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        width: MediaQuery.of(context).size.width * 0.3,
                                        height: MediaQuery.of(context).size.width * 0.3,
                                        child: Center(
                                            child: FaIcon(
                                          FontAwesomeIcons.user,
                                          color: Colors.black.withValues(alpha: 0.2),
                                          size: 60,
                                        ))),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      File(profileProvider.profile!.profileInfo!.photo!),
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
                                  Colors.black.withValues(alpha: 0.05)),
                            ),
                          ),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, _) {
                              _usernameTextController.text = userProvider.user!.username;
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
                                  onPressed: () => context.push("/profile/edit/username", extra: userProvider.user!),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.05)),
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
                                color: Colors.black.withValues(alpha: 0.5),
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
                              GestureDetector(
                                onTap: () {
                                  _showLogoutAlert();
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    color: HavkaColors.black.withValues(alpha: 0.05),
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
                              GestureDetector(
                                onTap: () => context.push(
                                "/profile/edit/terminate",
                                extra: widget.user,
                              ),
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                                  decoration: BoxDecoration(
                                    color: HavkaColors.black.withValues(alpha: 0.05),
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
