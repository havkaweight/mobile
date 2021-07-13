// import 'package:flutter/material.dart';
// import 'package:health_tracker/ui/widgets/screen_header.dart';
// import 'package:health_tracker/ui/screens/main_screen.dart';
// import 'package:health_tracker/ui/screens/sign_in_screen.dart';
// import 'package:health_tracker/ui/screens/devices_screen.dart';
// import 'package:health_tracker/model/user_product.dart';
// import 'package:health_tracker/ui/widgets/rounded_button.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'authorization.dart';
//
// class MeasurementScreen extends StatefulWidget {
//   final UserProduct product;
//
//   MeasurementScreen({
//     this.product
//   });
//
//   @override
//   _MeasurementScreenState createState() => _MeasurementScreenState();
// }
//
// class _MeasurementScreenState extends State<MeasurementScreen> {
//
//   // List<Chart> data;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // data = [
//     //   Chart(
//     //     name: 'Protein',
//     //     value: widget.product.protein,
//     //     color: charts.ColorUtil.fromDartColor(Color(0xFF5BBE78))
//     //   ),
//     //   Chart(
//     //     name: 'Fat',
//     //     value: widget.product.fat,
//     //     color: charts.ColorUtil.fromDartColor(Color(0xFFACBE78))
//     //   ),
//     //   Chart(
//     //       name: 'Carbs',
//     //       value: widget.product.carbs,
//     //       color: charts.ColorUtil.fromDartColor(Color(0xFFACBE78))
//     //   )
//     // ];
//   }
//
//   @override
//   Widget build (BuildContext context) {
//     // Random random = new Random();
//     // double weight = (100 + random.nextInt(900)) / 10;
//
//     // List<charts.Series<Chart, String>> series = [
//     //   charts.Series(
//     //       id: 'Label',
//     //       data: data,
//     //       domainFn: (Chart series, _) => series.name,
//     //       measureFn: (Chart series, _) => series.value,
//     //       colorFn: (Chart series, _) => series.color
//     //   )
//     // ];
//     // final dataValues = data.map((x) => x.value);
//     // final String val = (dataValues.first/dataValues.reduce((a, b) => a + b) * 100).toStringAsFixed(0);
//
//     return FutureBuilder(
//       future: checkLogIn(),
//       builder: (BuildContext context, AsyncSnapshot snapshot) {
//         var weight;
//         stream.listen((connectionState) {
//             print('here');
//             weight = flutterReactiveBle.readCharacteristic(characteristic);
//             print(weight);
//           }, onError: (Object error){
//             print('error');
//           });
//         return /*!isLoggedIn
//         ? SignInScreen()
//         :*/ Scaffold (
//       backgroundColor: Theme.of(context).backgroundColor,
//       body: Center(
//         child: Container(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               ScreenHeader(
//                 text: '$weight g'
//               ),
//               // Container(
//               //   height: 200,
//               //   child: Stack(
//               //       children: <Widget>[
//               //         charts.PieChart(
//               //             series,
//               //             defaultRenderer: charts.ArcRendererConfig(
//               //                 arcWidth: 10,
//               //                 arcRendererDecorators: [charts.ArcLabelDecorator(
//               //                     labelPosition: charts.ArcLabelPosition.inside
//               //                 )]
//               //             ),
//               //             animate: true
//               //         ),
//               //         Center(
//               //           child: Text(
//               //             '$val%',
//               //             style: TextStyle(
//               //                 fontSize: 30.0,
//               //                 color: Color(0xFF5BBE78),
//               //                 fontWeight: FontWeight.bold
//               //             ),
//               //           ),
//               //         )
//               //       ]
//               //   ),
//               // ),
//               RoundedButton(
//                 text: 'OK',
//                 onPressed: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
//                 },
//               )
//             ])
//         )
//       )
//     );
//       }
//     );
//   }
// }