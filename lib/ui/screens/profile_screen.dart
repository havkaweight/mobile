import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/model/profile_data_model.dart';
import 'package:havka/model/user_data_model.dart';
import 'package:havka/model/weight_history.dart';
import 'package:havka/ui/screens/daily_intake_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/model/data_items.dart';
import 'package:havka/model/user.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/screens/profile_edit_screen.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/widgets/line_chart.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/utils.dart';
import '../../main.dart';
import '../../model/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final ScrollController _profileScrollController = ScrollController();
  late Offset _appBarOffset;
  late double _appBarBlurRadius;

  @override
  void initState() {
    super.initState();
    _appBarOffset = Offset.zero;
    _appBarBlurRadius = 0.0;

    _profileScrollController.addListener(() {
      if (_profileScrollController.position.pixels <= 0.0) {
        setState(() {
          _appBarOffset = Offset.zero;
          _appBarBlurRadius = 0.0;
        });
      } else if (_profileScrollController.position.pixels > 5.0) {
        setState(() {
          _appBarOffset = Offset(0.0, 2.0);
          _appBarBlurRadius = 1.0;
        });
      } else {
        setState(() {
          _appBarOffset =
              Offset(0.0, _profileScrollController.position.pixels / 2.5);
          _appBarBlurRadius = _profileScrollController.position.pixels / 5.0;
        });
      }
    });
  }

  Widget _showUsername(String username) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: username,
          style: TextStyle(
            fontSize: 16,
          )),
    );
    textPainter.layout();
    return Text(
      "@${textPainter.width > MediaQuery.of(context).size.width * 0.8 ? '' : username}",
      style: TextStyle(
        fontSize: 16,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: HavkaColors.cream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: _appBarOffset,
                    blurRadius: _appBarBlurRadius,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer<UserDataModel>(builder: (context, user, _) {
                    return TextButton(
                      onPressed: () => context.push(
                          user.user!.email == "pasha@havka.com"
                              ? "/profile/chats"
                              : "/profile/chat",
                          extra: user.user!.email == "pasha@havka.com"
                              ? null
                              : user.user!.id as String?),
                      child: Text(
                        user.user!.email == "pasha@havka.com"
                            ? "Chats"
                            : "Support",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Colors.black.withOpacity(0.05)),
                      ),
                    );
                  }),
                  Consumer<UserDataModel>(builder: (context, user, _) {
                    return Consumer<ProfileDataModel>(
                        builder: (context, profile, _) {
                      return TextButton(
                        onPressed: () {
                          if (user.user == null ||
                              profile.userProfile == null) {
                            return;
                          }
                          context.push(
                            "/profile/edit",
                            extra: {
                              "user": user.user,
                              "user_profile": profile.userProfile
                            },
                          );
                        },
                        child: Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Colors.black.withOpacity(0.05)),
                        ),
                      );
                    });
                  }),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewPadding.top -
                  MediaQuery.of(context).viewPadding.bottom -
                  60 - 36 -
                  kBottomNavigationBarHeight,
              child: Scrollbar(
                controller: _profileScrollController,
                child: SingleChildScrollView(
                  controller: _profileScrollController,
                  child: Consumer<UserDataModel>(builder: (context, user, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: Consumer<ProfileDataModel>(
                                builder: (context, profile, _) {
                              return profile.userProfile!.profileInfo.photo ==
                                          null ||
                                      !File(profile
                                              .userProfile!.profileInfo.photo!)
                                          .existsSync()
                                  ? GestureDetector(
                                      onTap: () async {
                                        _pickImage();
                                      },
                                      onDoubleTap: () async {
                                        HapticFeedback.lightImpact();
                                        final String? token = await getToken();
                                        await Clipboard.setData(
                                            ClipboardData(text: token!));
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            border: Border.all(
                                                width: 4,
                                                color: Colors.black
                                                    .withOpacity(0.05)),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Center(
                                              child: FaIcon(
                                            FontAwesomeIcons.user,
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            size: 60,
                                          ))),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        File(profile
                                            .userProfile!.profileInfo.photo!),
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                    );
                            }),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                user.user == null
                                    ? SizedBox.shrink()
                                    : Text(
                                        showLabel(
                                          "@${user.user!.username}",
                                          maxSymbols: 20,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                Consumer<ProfileDataModel>(
                                    builder: (context, profile, _) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        profile.userProfile == null
                                            ? SizedBox.shrink()
                                            : Row(
                                                children: [
                                                  const FaIcon(
                                                    FontAwesomeIcons
                                                        .rulerVertical,
                                                    color: Colors.black,
                                                    size: 20,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(
                                                      8,
                                                      0,
                                                      20,
                                                      0,
                                                    ),
                                                    child: Text(
                                                      profile
                                                                      .userProfile
                                                                      ?.bodyStats
                                                                      .height
                                                                      ?.value !=
                                                                  null &&
                                                              profile
                                                                      .userProfile
                                                                      ?.bodyStats
                                                                      .height!
                                                                      .unit !=
                                                                  null
                                                          ? '${profile.userProfile?.bodyStats.height!.value!.toInt()} ${profile.userProfile?.bodyStats.height!.unit}'
                                                          : '-',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              FontAwesomeIcons.weightScale,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                20,
                                                0,
                                              ),
                                              child: Consumer<
                                                      WeightHistoryDataModel>(
                                                  builder: (context, value, _) {
                                                return Text(
                                                  value.data.isNotEmpty
                                                      ? "${value.getLastWeight().dy.toStringAsFixed(1)} kg"
                                                      : "-",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.man,
                                              color: Colors.black,
                                              size: 20,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                0,
                                                0,
                                              ),
                                              child: Text(
                                                profile.userProfile?.age == null
                                                    ? "-"
                                                    : "${profile.userProfile!.age} y.o.",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Consumer<WeightHistoryDataModel>(
                              builder: (context, value, _) {
                            return Consumer<ProfileDataModel>(
                                builder: (context, profileDataModel, _) {
                              final double? weight = context
                                  .read<WeightHistoryDataModel>()
                                  .getLastWeight()
                                  .dy;
                              final profile = profileDataModel.userProfile;
                              if (profile!.bodyStats.weight?.value != weight) {
                                profile.bodyStats.weight =
                                    Weight(unit: "kg", value: weight);
                                profileDataModel.updateProfile(profile);
                              }
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 5.0,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Daily Intake Goal",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: HavkaColors.black,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => context.push(
                                              "/profile/calculator",
                                              extra: value.getLastWeight().dy),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(Colors
                                                    .black
                                                    .withOpacity(0.05)),
                                          ),
                                          icon: Icon(
                                            FontAwesomeIcons.calculator,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.baseline,
                                            textBaseline:
                                                TextBaseline.alphabetic,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    right: 10.0),
                                                child: Text(
                                                  profileDataModel.userProfile
                                                              ?.dailyIntake ==
                                                          null
                                                      ? "-"
                                                      : "${profileDataModel.userProfile?.dailyIntake!.toInt()}",
                                                  style: TextStyle(
                                                    fontSize: 40,
                                                    color: HavkaColors.black,
                                                    fontWeight: FontWeight.bold,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "kcal / day",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: HavkaColors.black,
                                                  fontWeight: FontWeight.normal,
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            "based on your gender, age, height and weight",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            });
                          }),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5.0,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Weight Dynamics",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Consumer<WeightHistoryDataModel>(
                                            builder: (context, weightsData, _) {
                                          return AnimatedSwitcher(
                                              duration:
                                                  Duration(milliseconds: 300),
                                              child: weightsData.isSynced !=
                                                          null &&
                                                      weightsData.isSynced!
                                                  ? SizedBox.shrink()
                                                  : IconButton(
                                                      icon: Icon(Icons.sync),
                                                      color: Colors.black,
                                                      onPressed: () async {
                                                        await weightsData
                                                            .requestAccess();
                                                      },
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStatePropertyAll(
                                                                Colors.black
                                                                    .withOpacity(
                                                                        0.05)),
                                                      ),
                                                    ));
                                        }),
                                        // Consumer<WeightHistoryDataModel>(
                                        //     builder: (context, value, _) {
                                        //   return IconButton(
                                        //     onPressed: () async {
                                        //       final UserWeightItem? weight =
                                        //           await _buildWeightAddingModal(
                                        //               value.getLastWeight().dy);
                                        //       if (weight == null) {
                                        //         return;
                                        //       }
                                        //       value.addWeight(DataPoint(
                                        //           weight.createdAt, weight.value));
                                        //       setState(() {
                                        //         userWeight =
                                        //             value.getLastWeight().dy;
                                        //       });
                                        //     },
                                        //     style: ButtonStyle(
                                        //       backgroundColor:
                                        //           MaterialStatePropertyAll(Colors
                                        //               .black
                                        //               .withOpacity(0.05)),
                                        //     ),
                                        //     icon: Icon(
                                        //       Icons.add,
                                        //     ),
                                        //   );
                                        // }),
                                      ],
                                    ),
                                  ],
                                ),
                                Consumer<WeightHistoryDataModel>(
                                  builder: (BuildContext context,
                                      WeightHistoryDataModel value,
                                      Widget? child) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5.0,
                                        // horizontal: 5.0,
                                      ),
                                      height: 200,
                                      child: Builder(builder: (context) {
                                        if (!value.isLoaded) {
                                          return Center(
                                            child: HavkaProgressIndicator(),
                                          );
                                        }
                                        if (value.data.isEmpty) {
                                          return Center(
                                            child: Text("No data"),
                                          );
                                        }
                                        return HavkaLineChart(
                                          initialData: value.data,
                                          minTargetValue: 67,
                                          maxTargetValue: 69,
                                          showZeroAxis: false,
                                          valuesFormat: (num _) =>
                                              _.toStringAsFixed(1),
                                        );
                                      }),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserWeightItem?> _buildWeightAddingModal(double newWeight) async {
    bool showDatePicker = false;
    DateTime selectedDate = DateTime.now();
    double maxChildSize = 0.3;
    final List<int> weightIntegerList =
        List.generate(21, (index) => (newWeight.toInt() - 11 + index));
    final List<int> weightFloatingList = List.generate(10, (index) => index);
    double pickerWeightInteger = weightIntegerList[11].toDouble();
    double pickerWeightFloating =
        double.parse((newWeight - newWeight.floor()).toStringAsFixed(1));
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
                      // Adjust the radius as needed
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
                                  AnimatedSwitcher(
                                    duration: Duration(milliseconds: 200),
                                    child: !showDatePicker
                                        ? TextButton(
                                            child:
                                                Text(formatDate(selectedDate)),
                                            onPressed: () {
                                              setState(() {
                                                showDatePicker = true;
                                                maxChildSize = 0.6;
                                              });
                                            },
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                  TextButton(
                                    child: Text("Add"),
                                    onPressed: () {
                                      final double pickerWeight =
                                          pickerWeightInteger +
                                              pickerWeightFloating;
                                      final UserWeightItem uwi = UserWeightItem(
                                        value: pickerWeight,
                                        createdAt: selectedDate,
                                      );
                                      context.pop(uwi);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: showDatePicker
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                                  0.3 -
                                              MediaQuery.of(context)
                                                  .padding
                                                  .bottom -
                                              50,
                                      child: CupertinoDatePicker(
                                        use24hFormat: true,
                                        initialDateTime: DateTime.now(),
                                        minimumDate: DateTime.now()
                                            .subtract(Duration(days: 30)),
                                        maximumDate: DateTime.now(),
                                        onDateTimeChanged: (value) {
                                          selectedDate = value;
                                        },
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3 -
                                  MediaQuery.of(context).padding.bottom -
                                  50,
                              margin: EdgeInsets.symmetric(horizontal: 40.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      child: CupertinoPicker(
                                        itemExtent: 30,
                                        scrollController:
                                            FixedExtentScrollController(
                                          initialItem: 11,
                                        ),
                                        onSelectedItemChanged: (int value) {
                                          pickerWeightInteger =
                                              weightIntegerList[value]
                                                  .toDouble();
                                        },
                                        children: List.generate(
                                          weightIntegerList.length,
                                          (index) => Container(
                                            alignment:
                                                AlignmentDirectional.center,
                                            child: Text(
                                              (weightIntegerList[index])
                                                  .toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(left: 5.0, right: 40.0),
                                    child: Text(
                                      "kg",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: CupertinoPicker(
                                        itemExtent: 30,
                                        looping: true,
                                        scrollController:
                                            FixedExtentScrollController(
                                          initialItem:
                                              (pickerWeightFloating * 10)
                                                  .toInt(),
                                        ),
                                        onSelectedItemChanged: (int value) {
                                          pickerWeightFloating =
                                              weightFloatingList[value] / 10.0;
                                        },
                                        children: List.generate(
                                          weightFloatingList.length,
                                          (index) => Container(
                                            alignment:
                                                AlignmentDirectional.center,
                                            child: Text(
                                              (weightFloatingList[index])
                                                  .toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 5.0),
                                    child: Text(
                                      "g",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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

// Future _buildWeightingsHistory() {
//   return showModalBottomSheet(
//     isScrollControlled: true,
//     backgroundColor: Theme.of(context).colorScheme.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(15.0),
//         topRight: Radius.circular(15.0),
//       ),
//     ),
//     context: context,
//     builder: (BuildContext builder) {
//       final double mHeight = MediaQuery.of(context).size.height;
//       return SizedBox(
//         height: mHeight * 0.85,
//         child: Column(
//           children: [
//             Holder(),
//             Center(
//               child: Column(
//                 children: [
//                   UserConsumptionScreen(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Future _showCalendar() async {
//   return showModalBottomSheet(
//     backgroundColor: Theme.of(context).colorScheme.background,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(15.0),
//         topRight: Radius.circular(15.0),
//       ),
//     ),
//     context: context,
//     builder: (BuildContext context) {
//       final double mHeight = MediaQuery.of(context).size.height;
//       return SafeArea(
//         child: SizedBox(
//           height: mHeight * 0.9,
//           child: Column(
//             children: [
//               Holder(),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   Text('This widget is not ready yet.'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

// Future<dynamic> _buildScaleSearching(BuildContext context) async {
//   final List<DeviceService> servicesList =
//       await _apiRoutes.getDevicesServicesList();
//   return showModalBottomSheet(
//     isScrollControlled: true,
//     backgroundColor: Theme.of(context).colorScheme.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(15.0),
//         topRight: Radius.circular(15.0),
//       ),
//     ),
//     context: context,
//     builder: (builder) {
//       final double mHeight = MediaQuery.of(context).size.height;
//       return ClipRRect(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(15.0),
//           topRight: Radius.circular(15.0),
//         ),
//         child: SizedBox(
//           height: mHeight * 0.85,
//           child: Column(
//             children: [Holder(), Center(child: DevicesScreen(servicesList))],
//           ),
//         ),
//       );
//     },
//   );
// }
}
