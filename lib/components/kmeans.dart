import 'dart:convert';
import 'dart:math';

import 'package:intl/intl.dart';

import '../data/models/data_point.dart';
import '/data/models/pfc_data_item.dart';

class MealGroup {
  String label;
  List<DataPoint> records;

  MealGroup(this.label, this.records);

  DateTime get dtStart => records.map((e) => e.dx).reduce((value, element) => value.millisecondsSinceEpoch >= element.millisecondsSinceEpoch ? element : value);
  DateTime get dtEnd => records.map((e) => e.dx).reduce((value, element) => value.millisecondsSinceEpoch < element.millisecondsSinceEpoch ? element : value);

  DataPoint get summary => DataPoint(dtStart, records.fold(0, (previousValue, element) => previousValue + element.dy));

  @override
  toString() {
    return jsonEncode({"label": label, "records": records.toString(), "start": DateFormat("yyyy-MM-ddTHH:mm:ss").format(dtStart), "end": DateFormat("yyyy-MM-ddTHH:mm:ss").format(dtEnd)});
  }
}

double distanceSquared(DataPoint p1, DataPoint p2) {
  final timeDiff = p1.dx.difference(p2.dx).inMilliseconds.toDouble();
  return timeDiff * timeDiff + pow(p1.dy - p2.dy, 2);
}

String describeMealGroup(List<DataPoint> records) {
  // Implement logic to analyze records (e.g., average time, amount) and return a label (e.g., "Breakfast", "Late Lunch")
  return "Cluster ${records.length}"; // Placeholder for actual label generation
}

List<MealGroup> kMeansClustering(List<DataPoint> data, int k) {
  // Initialize centroids randomly
  List centroids = List.generate(k, (i) => data[Random().nextInt(data.length)]);

  // Loop until convergence (centroids don't change significantly)
  var didChange = true;
  final assignments = List.generate(data.length, (_) => -1);

  while (didChange) {
    didChange = false;
    // Assign each data point to the closest centroid
    for (var i = 0; i < data.length; i++) {
      var closestCentroidIndex = 0;
      var minDistance = double.infinity;
      for (var j = 0; j < k; j++) {
        final distance = distanceSquared(data[i], centroids[j]);
        if (distance < minDistance) {
          minDistance = distance;
          closestCentroidIndex = j;
        }
      }
      assignments[i] = closestCentroidIndex;
    }

    // Update centroids based on assigned points
    final newCentroids = List.generate(k, (_) => DataPoint(DateTime(0), 0));
    for (var i = 0; i < data.length; i++) {
      final assignment = assignments[i];
      newCentroids[assignment].dx = newCentroids[assignment].dx.add(data[i].dx.difference(newCentroids[assignment].dx));
      newCentroids[assignment].dy += data[i].dy;
    }

    for (var i = 0; i < k; i++) {
      final count = max(1, (newCentroids[i].dx.millisecond / 1000).round()); // Avoid division by zero
      newCentroids[i] = DataPoint(
          newCentroids[i].dx.subtract(Duration(milliseconds: newCentroids[i].dx.millisecond ~/ 1000)),
          newCentroids[i].dy / count);
      didChange = didChange || distanceSquared(centroids[i], newCentroids[i]) > 1e-6; // Check for significant centroid movement
    }

    centroids = newCentroids;
  }

  // Assign data points to final clusters and create MealGroup objects
  final groups = List.generate(k, (_) => MealGroup("", []));
  for (var i = 0; i < data.length; i++) {
    final assignment = assignments[i];
    groups[assignment].records.add(data[i]);
  }
  for (var i = 0; i < k; i++) {
    groups[i].label = describeMealGroup(groups[i].records); // Replace with your logic to label groups based on time, amount, dayOfWeek etc.
  }
  return groups;
}