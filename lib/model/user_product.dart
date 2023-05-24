import 'dart:math';

import 'package:health_tracker/model/product_amount.dart';
import 'package:health_tracker/model/product.dart';
import 'package:intl/intl.dart';

class UserProduct {
  final String? id;
  final Product? product;
  final String? userId;
  late final double? netWeightLeft;
  final ProductAmount? amount;
  final DateTime? createdAt;

  UserProduct({
    this.id,
    this.product,
    this.userId,
    this.netWeightLeft,
    this.amount,
    this.createdAt,
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
            : ProductAmount.fromJson(json['amount'] as Map<String, dynamic>),
        createdAt = json['created_at'] == null
            ? null
            : DateFormat('yyyy-MM-ddTHH:mm:ss')
                .parse(json['created_at'] as String, true)
                .toLocal();

  Map<String, dynamic> toJson() => {
        '_id': id,
        'product': product == null ? null : product!.toJson(),
        'user_id': userId,
        'net_weight_left': netWeightLeft,
        'amount': amount == null ? null : amount!.toJson(),
        'created_at': createdAt == null
            ? null
            : DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt!.toUtc()),
      };
}
