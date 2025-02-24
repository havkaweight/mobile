import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/presentation/providers/health_provider.dart';
import 'package:havka/presentation/providers/user_provider.dart';
import 'package:havka/presentation/widgets/profile_info_tile.dart';
import 'package:intl/intl.dart';
import '../../data/models/data_point.dart';
import '../../utils/format_date.dart';
import '../providers/profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/core/constants/colors.dart';
import '/presentation/screens/authorization.dart';
import '../widgets/charts/line_chart.dart';
import '/presentation/widgets/progress_indicator.dart';
import 'package:provider/provider.dart';
import '/data/models/user_profile.dart';

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

    Future.microtask(() async {
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchMe();

      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.fetchProfile();

      // final healthProvider = context.read<HealthProvider>();
      // await healthProvider.loadWeightData();
    });

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

  @override
  void dispose() {
    super.dispose();
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
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: HavkaColors.cream,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                  userProvider.user == null
                  ? Container()
                  : IconButton(
                      onPressed: () => context.push(
                          userProvider.user!.email == "pasha@havka.com"
                              ? "/profile/chats"
                              : "/profile/chat",
                          extra: userProvider.user!.email == "pasha@havka.com"
                              ? null
                              : userProvider.user!.id as String?),
                      icon: Icon(
                          Icons.forum,
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.black.withValues(alpha: 0.05)),
                      ),
                    ),
                  TextButton(
                        onPressed: () {
                          if (userProvider.user == null ||
                              profileProvider.profile == null) {
                            return;
                          }
                          context.push(
                            "/profile/edit",
                            extra: {
                              "user": userProvider.user,
                              "profile": profileProvider.profile,
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
                          backgroundColor: WidgetStatePropertyAll<Color>(
                              Colors.black.withValues(alpha: 0.05)),
                        ),
                      ),
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
                  child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          profileProvider.profile == null
                          ? Container()
                          : Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: profileProvider.profile!.profileInfo!.photo ==
                                          null ||
                                      !File(profileProvider
                                              .profile!.profileInfo!.photo!)
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
                                                Colors.black.withValues(alpha: 0.05),
                                            border: Border.all(
                                                width: 4,
                                                color: Colors.black
                                                    .withValues(alpha: 0.05)),
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
                                                Colors.black.withValues(alpha: 0.2),
                                            size: 60,
                                          ))),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(
                                        File(profileProvider
                                            .profile!.profileInfo!.photo!),
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                      ),
                                    ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                userProvider.user == null
                                    ? SizedBox.shrink()
                                    : Text(
                                        '@${userProvider.user!.username}',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        profileProvider.isLoading || profileProvider.profile?.bodyStats!.height == null
                                            ? Container()
                                            : ProfileInfoTile(
                                          icon: FontAwesomeIcons.arrowsUpDown,
                                          value: profileProvider.profile!.bodyStats!.height!.formattedValue,
                                        ),
                                        profileProvider.isLoading || profileProvider.profile?.bodyStats!.weight == null
                                        ? Container()
                                        : ProfileInfoTile(
                                          icon: FontAwesomeIcons.weightScale,
                                          value: profileProvider.profile!.bodyStats!.weight!.formattedValue,
                                        ),
                                        profileProvider.isLoading || profileProvider.profile?.profileInfo!.age == null
                                            ? Container()
                                            : ProfileInfoTile(
                                          icon: FontAwesomeIcons.userTie,
                                          value: profileProvider.profile?.profileInfo!.formattedAge,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Consumer<ProfileProvider>(
                              builder: (context, profileProvider, _) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 5.0,
                                  horizontal: 15.0,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
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
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Daily Intake Goal',
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: HavkaColors.black,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                            Text(
                                              'based on your gender, age, height and weight',
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                            )
                                          ],
                                        ),
                                        IconButton(
                                          onPressed: () => context.push(
                                              "/profile/calculator",
                                              extra: profileProvider.profile?.bodyStats?.weight?.value),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(Colors
                                                    .black
                                                    .withValues(alpha: 0.05)),
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
                                                  profileProvider.isLoading || profileProvider.profile?.dailyIntakeGoal == null
                                                      ? "-"
                                                      : "${profileProvider.profile?.dailyIntakeGoal}",
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
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 15.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Weight Dynamics',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'based on Apple Health',
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Row(
                                      //   children: [
                                      //     AnimatedSwitcher(
                                      //           duration:
                                      //               Duration(milliseconds: 300),
                                      //           child: IconButton(
                                      //                   icon: Icon(Icons.sync),
                                      //                   color: Colors.black,
                                      //                   onPressed: () => {},
                                      //                   style: ButtonStyle(
                                      //                     backgroundColor:
                                      //                         WidgetStatePropertyAll(
                                      //                             Colors.black
                                      //                                 .withValues(alpha: 0.05)),
                                      //                   ),
                                      //                 )),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                                  height: 200,
                                  child: Consumer<HealthProvider>(
                                    builder: (
                                        context,
                                        healthProvider,
                                        child) {
                                      return Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                        child: !healthProvider.isSynced
                                            ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.05))),
                                                  child: Text('Sync data'),
                                                  onPressed: () async {
                                                    await healthProvider
                                                        .enableSync();
                                                  },
                                                ),
                                                Center(
                                                  child: Text(
                                                    'Not synced',
                                                    style: TextStyle(fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            )
                                            : healthProvider.weightHistory.isEmpty
                                              ? Center(child: HavkaProgressIndicator())
                                              : HavkaLineChart(
                                                initialData: healthProvider.weightHistory.map((element) => DataPoint.fromHealthData(element)).toList(),
                                                minTargetValue: 66,
                                                maxTargetValue: 69,
                                                verticalAxisLabelsFormat: (number) => number.toStringAsFixed(0),
                                                horizontalAxisLabelsFormat: (number) => DateFormat("d").format(DateTime.fromMillisecondsSinceEpoch(number.toInt())),
                                                valuesFormat: (num number) =>
                                                    number.toStringAsFixed(1),
                                              ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
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
