import 'package:havka/data/models/product/product_amount_model.dart';
import 'package:havka/data/models/product/product_model.dart';

import '../../../domain/entities/product/fridge_item.dart';
import '../fridge/fridge_model.dart';

class FridgeItemModel {
  final String? id;
  final Map<String, dynamic> product;
  final Map<String, dynamic> initialAmount;
  final Map<String, dynamic> amount;
  final DateTime? createdAt;

  FridgeItemModel({
    this.id,
    required this.product,
    required this.initialAmount,
    required this.amount,
    this.createdAt,
  });

  @override
  String toString() => this.toJson().toString();

  factory FridgeItemModel.fromJson(Map<String, dynamic> json) {
    return FridgeItemModel(
      id: json['_id'],
      product: json['product'],
      initialAmount: json['initial_amount'],
      amount: json['amount'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product': product,
      'initial_amount': initialAmount,
      'amount': amount,
    };
  }

  static FridgeItemModel fromDomain(FridgeItem fridgeItem) {
    return FridgeItemModel(
      id: fridgeItem.id,
      product: ProductModel.fromDomain(fridgeItem.product).toJson(),
      initialAmount: ProductAmountModel.fromDomain(fridgeItem.initialAmount).toJson(),
      amount: ProductAmountModel.fromDomain(fridgeItem.amount).toJson(),
      createdAt: fridgeItem.createdAt,
    );
  }

  FridgeItem toDomain() {
    return FridgeItem(
      id: id,
      product: ProductModel.fromJson(product).toDomain(),
      initialAmount: ProductAmountModel.fromJson(initialAmount).toDomain(),
      amount: ProductAmountModel.fromJson(amount).toDomain(),
      createdAt: createdAt!,
    );
  }
}