import 'package:intl/intl.dart';

import '../../domain/entities/health/health_data.dart';

class DataPoint {
  DateTime dx;
  double dy;

  DataPoint(this.dx, this.dy);

  @override
  String toString() {
    return "DataPoint(dx: $dx, dy: $dy)";
  }

  @override
  bool operator == (Object other) {
    if(other is DataPoint) {
      return dx.millisecondsSinceEpoch == other.dx.millisecondsSinceEpoch &&
          dy == other.dy;
    }
    return false;
  }

  DataPoint.fromJson(Map<String, dynamic> json)
      : dx = DateFormat("yyyy-MM-ddTHH:mm:ss").parse(json["dx"]),
        dy = json["dy"];

  static DataPoint fromHealthData(HealthData healthData) {
    return DataPoint(
      healthData.date,
      healthData.weight,
    );
  }


  toJson() => {
    "dx": DateFormat("yyyy-MM-ddTHH:mm:ss").format(dx),
    "dy": dy,
  };
}