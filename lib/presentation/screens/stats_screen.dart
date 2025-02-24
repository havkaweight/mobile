import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/presentation/providers/consumption_provider.dart';
import 'package:havka/presentation/providers/profile_provider.dart';
import '../../data/models/data_item.dart';
import '../../data/models/data_point.dart';
import '../../domain/entities/consumption/user_consumption_item.dart';
import '/presentation/screens/authorization.dart';
import '/presentation/screens/scrolling_behavior.dart';
import '/presentation/screens/user_consumption_screen.dart';
import '../widgets/charts/bar_chart_timeline.dart';
import '../widgets/charts/line_chart.dart';
import '/presentation/widgets/progress_indicator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '/components/kmeans.dart';
import '/core/constants/utils.dart';

List<DataPoint> extractTodayDailyKcals(
    List<UserConsumptionItem> userConsumption,
    {DateTime? selectedDate}) {
  final DateTime currentDate = selectedDate ?? DateTime.now();

  final todayUserConsumption = userConsumption.where(
      (element) => Utils().areDatesEqual(element.consumedAt, currentDate));
  final List<DataPoint> data = [];
  for (final UserConsumptionItem uci in todayUserConsumption) {
    data.add(
      DataPoint(
          uci.consumedAt,
          uci.product!.nutrition!.energy!.kcal! /
              uci.product!.nutrition!.valuePerInBaseUnit! *
              uci.consumedAmount!.value *
              uci.consumedAmount!.serving.valueInBaseUnit),
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

    Future.microtask(() async {
      final consumptionProvider = context.read<ConsumptionProvider>();
      await consumptionProvider.fetchConsumption();
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
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
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
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
      final List<DataItem> newDailyKcals =
          jsonData.map<DataItem>((json) => DataItem.fromJson(json)).toList();
      _data = newDailyKcals;
      _selectedBar = _data.last;
      notifyListeners();
    }
    // final List<UserConsumptionItem> userConsumption = await ApiRoutes().getUserConsumption();
    // _data = extractDailyKcals(userConsumption);
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
    return Container(
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
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
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
                        color: Colors.black.withValues(alpha: 0.6),
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
                        backgroundColor: WidgetStatePropertyAll<Color>(
                            Colors.black.withValues(alpha: 0.05)),
                      ),
                      onPressed: _buildWeightingsHistory,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            height: 200,
            child: Consumer<ConsumptionProvider>(
                builder: (context, consumptionProvider, _) {
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: consumptionProvider.isLoading
                    ? Container(
                        child: Center(child: HavkaProgressIndicator()))
                    : HavkaBarChart(
                        initialData: consumptionProvider.extractDailyEnergy(),
                        // selectedBar: weeklyProgressDataModel.selectedBar,
                        // targetValue: profileProvider.profile!.dailyIntakeGoal.toDouble(),
                        // onSelectedBar: (di) {
                        //   setState(() {
                        //     weeklyProgressDataModel.selectBar(di);
                        //     context.read<DailyProgressDataModel>().getDataByDate(di.date);
                        //   });
                        // },
                      ),
              );
            }),
          ),
        ],
      ),
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
      _data = jsonData
          .map<DataPoint>(
              (json) => DataPoint.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
    // _userConsumption = await ApiRoutes().getUserConsumption();
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
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Daily Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "shown in consumed kcal",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Consumer<ConsumptionProvider>(
                  builder: (context, consumptionProvider, child) {
                    if (consumptionProvider.isLoading) {
                      return HavkaProgressIndicator();
                    }
                    return Text(
                      DateFormat("d MMM")
                          .format(consumptionProvider.consumption.map((e) => e.consumedAt).reduce((value, element) => value.isAfter(element) ? value : element)),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              height: 200,
              child: Consumer<ConsumptionProvider>(
                builder: (context, consumptionProvider, child) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: consumptionProvider.isLoading
                      ? Center(child: HavkaProgressIndicator())
                      : consumptionProvider.extractTodayDailyEnergy(consumptionProvider.consumption).isEmpty
                        ? GestureDetector(
                            onTap: () => context.go("/fridge"),
                            child: Container(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5.0),
                                    child: Icon(
                                      CupertinoIcons.plus,
                                      color: Colors.black.withValues(alpha: 0.6),
                                      size: 48,
                                    ),
                                  ),
                                  Text(
                                    "Wanna add some food?",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withValues(alpha: 0.6),
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
                            child: Consumer<ProfileProvider>(
                                builder: (context, profileProvider, _) {
                              return HavkaLineChart(
                                initialData: groupMeals
                                    ? kMeansClustering(consumptionProvider.extractTodayDailyEnergy(consumptionProvider.consumption), 4)
                                        .where(
                                            (element) => element.records.length > 0)
                                        .map((e) => e.summary)
                                        .toList()
                                    : consumptionProvider.extractTodayDailyEnergy(consumptionProvider.consumption),
                                targetValue: profileProvider.profile?.dailyIntakeGoal
                                    .toDouble() ?? null,
                                targetLabel: "Daily Intake",
                                showZeroAxis: true,
                                isCumulative: true,
                                fillArea: true,
                                showTime: true,
                                // minDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                                maxDateTime:
                                    // DateTime(
                                    //     dailyProgressData.data.first.dx.year,
                                    //     dailyProgressData.data.first.dx.month,
                                    //     dailyProgressData.data.first.dx.day
                                    // )
                                    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
                                    .add(Duration(days: 1))
                                    .subtract(Duration(seconds: 1)),
                              );
                            }),
                          ),
                  );
                }
              ),
            ),
        ],
      ),
    );
  }
}
