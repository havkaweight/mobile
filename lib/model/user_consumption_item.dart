import 'dart:math';

import 'package:health_tracker/model/product_amount.dart';
import 'package:health_tracker/model/product.dart';
import 'package:health_tracker/model/user_product.dart';
import 'package:intl/intl.dart';

class UserConsumptionItem {
  final String? id;
  final Product? product;
  final UserProduct? userProduct;
  final String? userId;
  final ProductAmount? amount;
  final DateTime? createdAt;
  final DateTime? consumedAt;

  UserConsumptionItem({
    this.id,
    this.product,
    this.userProduct,
    this.userId,
    this.amount,
    this.createdAt,
    this.consumedAt,
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
            : ProductAmount.fromJson(json['amount'] as Map<String, dynamic>),
        createdAt = json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        consumedAt = json['consumed_at'] == null
            ? null
            : DateTime.parse(json['consumed_at'] as String);

  Map<String, dynamic> toJson() => {
        '_id': id,
        'product': product == null ? null : product!.toJson(),
        'user_id': userId,
        'amount': amount == null ? null : amount!.toJson(),
        'created_at':
            DateFormat('yyyy-MM-ddTHH:mm:ss.000000').format(createdAt!),
        'consumed_at':
            DateFormat('yyyy-MM-ddTHH:mm:ss.000000').format(consumedAt!),
      };
}
