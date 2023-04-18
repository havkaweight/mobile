import 'dart:math';

import 'package:health_tracker/model/amount.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user_product.dart';

class UserConsumptionItem {
  final String? id;
  final Product? product;
  final UserProduct? userProduct;
  final String? userId;
  final Amount? amount;

  UserConsumptionItem({
    this.id,
    this.product,
    this.userProduct,
    this.userId,
    this.amount,
  });

  UserConsumptionItem.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        product = json['product'] == null
            ? null
            : Product.fromJson(json['product'] as Map<String, dynamic>),
        userProduct = json['user_product'] == null
            ? null
            : UserProduct.fromJson(
                json['user_product'] as Map<String, dynamic>),
        userId = json['user_id'] as String?,
        amount = json['amount'] == null
            ? null
            : Amount.fromJson(json['amount'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        '_id': id,
        'product': product == null ? null : product!.toJson(),
        'user_id': userId,
        'amount': amount == null ? null : amount!.toJson(),
      };
}
