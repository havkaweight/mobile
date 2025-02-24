import 'package:flutter/material.dart';
import 'package:havka/core/constants/colors.dart';
import 'package:havka/domain/entities/consumption/consumed_amount.dart';
import 'package:havka/domain/entities/consumption/user_consumption_item.dart';
import 'package:intl/intl.dart';
import '../../core/constants/utils.dart';
import '../../data/models/data_item.dart';
import '../../data/models/data_point.dart';
import '../../domain/repositories/consumption/consumption_repository.dart';
import '../../domain/entities/product/product.dart';
import '../../utils/get_days_from_period.dart';

class ConsumptionProvider extends ChangeNotifier {
  final ConsumptionRepository _repository;

  List<UserConsumptionItem> _consumption = [];
  List<UserConsumptionItem> _productConsumption = [];
  UserConsumptionItem? _createdConsumptionItem = null;
  bool _isLoading = false;

  ConsumptionProvider({required ConsumptionRepository repository}) : _repository = repository;

  List<UserConsumptionItem> get consumption => _consumption;
  List<UserConsumptionItem> get productConsumption => _productConsumption;
  UserConsumptionItem? get createdConsumptionItem => _createdConsumptionItem;
  bool get isLoading => _isLoading;

  Future<void> fetchConsumption() async {
    _isLoading = true;
    notifyListeners();

    try {
      _consumption = await _repository.getConsumptionItems();
    } catch (e) {
      throw('Failed to fetch consumption items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchConsumptionByProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      _productConsumption = await _repository.getConsumptionItemsByProduct(product);
    } catch (e) {
      throw('Failed to fetch consumptions items: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addConsumption(UserConsumptionItem userConsumptionItem) async {
    try {
      final addedConsumptionItem = await _repository.addConsumptionItem(userConsumptionItem);
      _createdConsumptionItem = addedConsumptionItem;
      _consumption.add(addedConsumptionItem);
      notifyListeners();
    } catch (e) {
      throw('Failed to add consumption: $e');
    }
  }

  Future<void> deleteConsumption(UserConsumptionItem userConsumptionItem) async {
    try {
      await _repository.deleteConsumptionItem(userConsumptionItem.id!);
      _consumption.remove(userConsumptionItem);
      notifyListeners();
    } catch (e) {
      throw('Failed to delete consumption: $e');
    }
  }

  List<DataItem> extractDailyEnergy() {
    final DateTime currentDate = DateTime.now();
    final DateTime maxDate =
    DateTime(currentDate.year, currentDate.month, currentDate.day);
    final DateTime minDate = maxDate.subtract(const Duration(days: 6));
    final List<DateTime> datesPeriod = getDaysFromPeriod(minDate, maxDate);
    final List<DataItem> data = [];
    for (final DateTime date in datesPeriod) {
      data.add(
        DataItem(
          _consumption.fold(0, (previousValue, element) {
            if (element.consumedAt
                .difference(date)
                .inDays ==
                0 &&
                element.consumedAt.isAfter(date)) {
              return previousValue += element.product!.nutrition!.energy!.kcal!
                  / element.product!.nutrition!.valuePerInBaseUnit!
                  * element.consumedAmount!.value
                  * element.consumedAmount!.serving.valueInBaseUnit;
            }
            return previousValue;
          }),
          DateFormat('MMM d').format(date),
          date,
          HavkaColors.green,
        ),
      );
    }
    return data;
  }

  List<DataPoint> extractTodayDailyEnergy(
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
}
