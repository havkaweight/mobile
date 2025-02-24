import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/presentation/widgets/progress_indicator.dart';
import '../providers/profile_provider.dart';
import '/core/constants/colors.dart';
import '/presentation/widgets/slider.dart';
import 'package:provider/provider.dart';


class DailyIntakeScreen extends StatefulWidget {
  @override
  _DailyIntakeScreenState createState() => _DailyIntakeScreenState();
}

class _DailyIntakeScreenState extends State<DailyIntakeScreen>
    with WidgetsBindingObserver {

  late double userHeight;
  late double userWeight;
  late double userAge;

  @override
  void initState() {
    super.initState();

    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    userHeight = profileProvider.profile!.bodyStats!.height!.value!;
    userWeight = profileProvider.profile!.bodyStats!.weight!.value!;
    userAge = profileProvider.profile!.profileInfo!.age!.toDouble();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileProvider profileProvider = Provider.of<ProfileProvider>(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildDailyIntakeScreen(profileProvider),
    );
  }

  Widget _buildDailyIntakeScreen(ProfileProvider profileProvider) {
    return PhysicalModel(
      color: HavkaColors.cream,
      elevation: 20,
      child: SafeArea(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Column(
                    children: [
                      // Container(
                      //   margin: EdgeInsets.symmetric(vertical: 10.0),
                      //   child: Icon(
                      //     FontAwesomeIcons.calculator,
                      //     size: 60,
                      //   ),
                      // ),
                      Container(
                        child: Text(
                          "Daily Intake Calculator",
                          style: TextStyle(
                            fontSize: 24,
                            color: HavkaColors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          'This intake calculator is based on the Harris-Benedict equation. Here you can change age, height and weight to see your intake perfect daily goal.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Container(
                        child: profileProvider.isLoading
                          ? HavkaProgressIndicator()
                          : profileProvider.profile == null
                            ? Text("Add date of birthday, weight and height to see your intake perfect daily goal.")
                            : Text(
                                (userWeight * 10.0 + userHeight * 6.25 + userAge * 5.0 + 5.0).toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 48,
                                  color: HavkaColors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                            ),
                      ),
                      Text(
                        "kcal / day",
                        style: TextStyle(
                          fontSize: 24,
                          color: HavkaColors.black,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text("Age"),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              height: 40,
                              child: HavkaSlider(
                                value: userAge,
                                minValue: 14,
                                maxValue: 100,
                                onUpdate: (value) {
                                  setState(() {
                                    userAge = value;
                                  });
                                },
                                lineColor: HavkaColors.energy,
                                pointColor: HavkaColors.energy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text("Weight"),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              height: 40,
                              child: HavkaSlider(
                                maxValue: 120,
                                value: userWeight,
                                onUpdate: (value) {
                                  setState(() {
                                    userWeight = value;
                                  });
                                },
                                lineColor: HavkaColors.energy,
                                pointColor: HavkaColors.energy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            Container(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text("Height"),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              height: 40,
                              child: HavkaSlider(
                                value: userHeight,
                                maxValue: 250,
                                onUpdate: (value) {
                                  setState(() {
                                    userHeight = value;
                                  });
                                },
                                lineColor: HavkaColors.energy,
                                pointColor: HavkaColors.energy,
                              ),
                            ),
                          ],
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
    );
  }
}
