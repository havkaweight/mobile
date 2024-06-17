import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/api/methods.dart';
import 'package:havka/model/data_items.dart';
import 'package:havka/model/user_consumption_item.dart';
import 'package:havka/model/user_data_model.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/screens/scrolling_behavior.dart';
import 'package:havka/ui/screens/user_consumption_screen.dart';
import 'package:havka/ui/widgets/bar_chart_timeline.dart';
import 'package:havka/ui/widgets/holder.dart';
import 'package:havka/ui/widgets/line_chart.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:havka/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../components/kmeans.dart';
import '../../constants/utils.dart';
import '../../model/profile_data_model.dart';

List<DataPoint> extractTodayDailyKcals(
    List<UserConsumptionItem> userConsumption, {DateTime? selectedDate}) {
  final DateTime currentDate = selectedDate ?? DateTime.now();

  final todayUserConsumption = userConsumption.where(
      (element) => Utils().areDatesEqual(element.consumedAt, currentDate));
  final List<DataPoint> data = [];
  for (final UserConsumptionItem uci in todayUserConsumption) {
    data.add(
      DataPoint(
        uci.consumedAt,
        uci.product!.nutrition!.energy!.kcal!
            / uci.product!.nutrition!.valuePerInBaseUnit!
            * uci.consumedAmount!.value
            * uci.consumedAmount!.serving.valueInBaseUnit
      ),
    );
  }
  return data;
}

List<DataItem> extractDailyKcals(List<UserConsumptionItem> userConsumption) {
  final DateTime currentDate = DateTime.now();
  final DateTime maxDate =
      DateTime(currentDate.year, currentDate.month, currentDate.day);
  final DateTime minDate = maxDate.subtract(const Duration(days: 6));
  final List<DateTime> datesPeriod = getDaysInBetween(minDate, maxDate);
  final List<DataItem> data = [];
  for (final DateTime date in datesPeriod) {
    data.add(
      DataItem(
        userConsumption.fold(0, (previousValue, element) {
          if ((element.consumedAt ?? element.createdAt)!
                      .difference(date)
                      .inDays ==
                  0 &&
              (element.consumedAt ?? element.createdAt)!.isAfter(date)) {
            return previousValue += element.product!.nutrition!.energy!.kcal!
                / element.product!.nutrition!.valuePerInBaseUnit!
                * element.consumedAmount!.value
                * element.consumedAmount!.serving.valueInBaseUnit;
          }
          return previousValue;
        }),
        DateFormat('MMM d').format(date),
        date,
        Colors.amber[500]!,
      ),
    );
  }
  return data;
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {

  DataItem? selectedBar = null;

  @override
  void initState() {
    super.initState();
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
      body: StatsScreen(),
    );
  }

  Future<void> _refreshStatsScreen() async {
    context.read<WeeklyProgressDataModel>().initData();
    context.read<DailyProgressDataModel>().initData();
  }

  Widget StatsScreen() {
    return SafeArea(
      child: Container(
        child: Platform.isAndroid
            ? RefreshIndicator(
          onRefresh: _refreshStatsScreen,
          child: ScrollConfiguration(
            behavior: CustomBehavior(),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        WeeklyProgressWidget(),
                        DailyProgressWidget(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: _refreshStatsScreen,
          child: ScrollConfiguration(
            behavior: CustomBehavior(),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        WeeklyProgressWidget(),
                        DailyProgressWidget(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class WeeklyProgressDataModel extends ChangeNotifier {
  List<DataItem> _data = [];
  List<DataItem> get data => _data;

  DataItem? _selectedBar;
  DataItem? get selectedBar => _selectedBar;

  WeeklyProgressDataModel() {
    initData();
  }

  void selectBar(DataItem di) async {
    _selectedBar = di;
    notifyListeners();
  }

  void initData() async {
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_daily_kcals-$userId.json";
    final dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync()) as Iterable;
      final List<DataItem> newDailyKcals = jsonData.map<DataItem>(
            (json) => DataItem.fromJson(json)
      ).toList();
      _data = newDailyKcals;
      _selectedBar = _data.last;
      notifyListeners();
    }
    final List<UserConsumptionItem> userConsumption = await ApiRoutes().getUserConsumption();
    _data = extractDailyKcals(userConsumption);
    _selectedBar = _data.last;
    file.writeAsStringSync(
      jsonEncode(_data.map((e) => e.toJson()).toList()),
      flush: true,
    );
    notifyListeners();
  }
}

class WeeklyProgressWidget extends StatefulWidget {
  @override
  _WeeklyProgressWidgetState createState() => _WeeklyProgressWidgetState();
}

class _WeeklyProgressWidgetState extends State<WeeklyProgressWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  Future _buildWeightingsHistory() {
    return showModalBottomSheet(
      useRootNavigator: true,
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) => UserConsumptionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeeklyProgressDataModel>(
      builder: (context, weeklyProgressDataModel, _) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: 15.0,
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Weekly Progress",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "shown in consumed kcal per day",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.history),
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Colors.black.withOpacity(0.05)),
                        ),
                        onPressed: _buildWeightingsHistory,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  top: 20.0,
                  bottom: 5.0,
                ),
                child: SizedBox(
                  height: 200,
                  child: weeklyProgressDataModel.data.isEmpty
                      ? Container(child: Center(child: HavkaProgressIndicator()))
                      : Consumer<ProfileDataModel>(
                        builder: (context, profileDataModel, _) {
                          return HavkaBarChart(
                              initialData: weeklyProgressDataModel.data,
                              selectedBar: weeklyProgressDataModel.selectedBar,
                              targetValue: profileDataModel.userProfile?.dailyIntake,
                              onSelectedBar: (di) {
                                setState(() {
                                  weeklyProgressDataModel.selectBar(di);
                                  context.read<DailyProgressDataModel>().getDataByDate(di.date);
                                });
                              },
                            );
                        }
                      ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class DailyProgressDataModel extends ChangeNotifier {
  List<DataPoint> _data = [];
  List<DataPoint> get data => _data;

  List<UserConsumptionItem> _userConsumption = [];
  List<UserConsumptionItem> get userConsumption => _userConsumption;

  DailyProgressDataModel() {
    initData();
  }

  void getDataByDate(DateTime dt) {
    _data = extractTodayDailyKcals(_userConsumption, selectedDate: dt);
    // _data = kMeansClustering(_data, 4).where((element) => element.records.length>0).map((e) => e.summary).toList();
    notifyListeners();
  }

  Future<void> initData() async {
    final token = await getToken();
    final userId = await getUserId(token);
    final String fileName = "user_today_daily_kcals-$userId.json";
    final dir = await getTemporaryDirectory();
    final File file = File("${dir.path}/$fileName");
    if (file.existsSync()) {
      final jsonData = jsonDecode(file.readAsStringSync()) as List;
      _data = jsonData.map<DataPoint>(
              (json) => DataPoint.fromJson(json as Map<String, dynamic>)
      ).toList();
      notifyListeners();
    }
    _userConsumption = await ApiRoutes().getUserConsumption();
    _data = extractTodayDailyKcals(_userConsumption);
    file.writeAsStringSync(
      jsonEncode(_data.map((e) => e.toJson()).toList()),
      flush: true,
    );
    notifyListeners();
  }
}

class DailyProgressWidget extends StatefulWidget {

  @override
  _DailyProgressWidgetState createState() => _DailyProgressWidgetState();
}

class _DailyProgressWidgetState extends State<DailyProgressWidget> {

  late bool groupMeals;

  @override
  void initState() {
    super.initState();
    groupMeals = false;
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15.0,
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
        children: [
          Container(
            alignment: AlignmentDirectional.centerStart,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daily Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<WeeklyProgressDataModel>(
                      builder: (context, weeklyProgressData, _) {
                        return Text(
                          weeklyProgressData.selectedBar == null
                              ? "-"
                              : DateFormat("d MMM").format(weeklyProgressData.selectedBar!.date),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    ),
                  ],
                ),
                Text(
                  "shown in consumed kcal",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Consumer<DailyProgressDataModel>(
              builder: (context, dailyProgressData, _) {
              return Container(
                padding: EdgeInsets.symmetric(
                  vertical: 5.0,
                ),
                height: 200,
                child: dailyProgressData.data.isEmpty
                    ? InkWell(
                      onTap: () => context.go("/fridge"),
                      child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 5.0),
                                child: Icon(
                                  CupertinoIcons.plus_circle,
                                  color: Colors.black.withOpacity(0.6),
                                  size: 48,
                                ),
                              ),
                              Text(
                                "Wanna add some food?",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                    )
                    : InkWell(
                  onDoubleTap: () {
                    setState(() {
                      groupMeals = !groupMeals;
                    });
                  },
                      child: Consumer<ProfileDataModel>(
                        builder: (context, profileDataModel, _) {
                          return HavkaLineChart(
                                            initialData: groupMeals ? kMeansClustering(dailyProgressData.data, 4).where((element) => element.records.length>0).map((e) => e.summary).toList() : dailyProgressData.data,
                                            targetValue: profileDataModel.userProfile?.dailyIntake,
                                            targetLabel: "Daily Intake",
                                            showZeroAxis: true,
                                            isCumulative: true,
                                            fillArea: true,
                                            showTime: true,
                                            // minDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                            maxDateTime: DateTime(dailyProgressData.data.first.dx.year,
                            dailyProgressData.data.first.dx.month, dailyProgressData.data.first.dx.day)
                            .add(Duration(days: 1))
                            .subtract(Duration(seconds: 1)),
                                          );
                        }
                      ),
                    ),
              );
            }
          ),
        ],
      ),
    );
  }
}
