import 'dart:math';

import 'package:health_tracker/model/amount.dart';
import 'package:health_tracker/model/product.dart';

class UserProduct {
  final String? id;
  final Product? product;
  final String? userId;
  late final double? netWeightLeft;
  final Amount? amount;

  UserProduct({
    this.id,
    this.product,
    this.userId,
    this.netWeightLeft,
    this.amount,
  });

  UserProduct.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        product = json['product'] == null
            ? null
            : Product.fromJson(json['product'] as Map<String, dynamic>),
        userId = json['user_id'] as String?,
        netWeightLeft = Random().nextDouble(),
        amount = json['amount'] == null
            ? null
            : Amount.fromJson(json['amount'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
        '_id': id,
        'product': product == null ? null : product!.toJson(),
        'user_id': userId,
        'net_weight_left': netWeightLeft,
        'amount': amount == null ? null : amount!.toJson()
      };
}
