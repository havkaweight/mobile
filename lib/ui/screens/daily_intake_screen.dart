import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/model/profile_data_model.dart';
import 'package:havka/ui/widgets/slider.dart';
import 'package:provider/provider.dart';


class DailyIntakeScreen extends StatefulWidget {
  final double weight;
  const DailyIntakeScreen({
    required this.weight,
});
  @override
  _DailyIntakeScreenState createState() => _DailyIntakeScreenState();
}

class _DailyIntakeScreenState extends State<DailyIntakeScreen>
    with WidgetsBindingObserver {
  late double userWeight;
  late double userHeight;
  late double userAge;
  late String userGender;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<ProfileDataModel>();
    userWeight = userProfile.userProfile!.bodyStats.weight!.value!;
    userHeight = userProfile.userProfile!.bodyStats.height!.value!;
    userAge = userProfile.userProfile!.age!.toDouble();
    userGender = userProfile.userProfile!.profileInfo.gender!;
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
      body: _buildDailyIntakeScreen(),
    );
  }

  Widget _buildDailyIntakeScreen() {
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
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.0),
                        child: Icon(
                          FontAwesomeIcons.calculator,
                          size: 60,
                        ),
                      ),
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
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                            (switch(userGender) {
                          "male" => userWeight * 10.0 + userHeight * 6.25 + userAge * 5.0 + 5.0,
                          "female" => userWeight * 10.0 + userHeight * 6.25 + userAge * 5.0 - 161.0,
                          _ => userWeight * 10.0 + userHeight * 6.25 + userAge * 5.0 - 161.0,
                          }).toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 60,
                            color: HavkaColors.black,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Text(
                        "kcal / day",
                        style: TextStyle(
                          fontSize: 30,
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
