import 'package:havka/domain/entities/consumption/consumed_amount.dart';
import '../product/serving_model.dart';

class ConsumedAmountModel {
  final Map<String, dynamic> serving;
  final double value;

  const ConsumedAmountModel({
    required this.serving,
    required this.value,
  });

  @override
  String toString() => this.toJson().toString();

  factory ConsumedAmountModel.fromJson(Map<String, dynamic> json) {
    return ConsumedAmountModel(
      serving: json["serving"] as Map<String, dynamic>,
      value: json["value"],
    );
  }

  Map<String, dynamic> toJson() => {
    "serving": serving,
    "value": value,
  };

  ConsumedAmount toDomain() {
    return ConsumedAmount(
      serving: ServingModel.fromJson(serving).toDomain(),
      value: value,
    );
  }

  static ConsumedAmountModel fromDomain(ConsumedAmount consumedAmount) {
    return ConsumedAmountModel(
      serving: ServingModel.fromDomain(consumedAmount.serving).toJson(),
      value: consumedAmount.value,
    );
  }
}