import 'package:havka/model/product_amount.dart';
import 'package:havka/model/product.dart';
import 'package:intl/intl.dart';

class UserFridgeItem {
  final String? id;
  final String? productId;
  final Product? product;
  final String? userId;
  final String? fridgeId;
  ProductAmount? initialAmount;
  ProductAmount? amount;
  final DateTime createdAt;

  UserFridgeItem({
    this.id,
    this.productId,
    this.product,
    this.userId,
    this.fridgeId,
    this.initialAmount,
    this.amount,
    required this.createdAt,
  });


  @override
  bool operator ==(Object other) {
    return other is UserFridgeItem
        && id == other.id;
  }


  @override
  toString() {
    return toJson().toString();
  }

  UserFridgeItem.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        productId = json['product_id'] as String?,
        product = json['product'] == null
            ? null
            : Product.fromJson(json['product'] as Map<String, dynamic>),
        userId = json['user_id'] as String?,
        fridgeId = json['fridge_id'] as String?,
        initialAmount = json['initial_amount'] == null
            ? null
            : ProductAmount.fromJson(json['initial_amount'] as Map<String, dynamic>),
        amount = json['amount'] == null
            ? null
            : ProductAmount.fromJson(json['amount'] as Map<String, dynamic>),
        createdAt = DateFormat('yyyy-MM-ddTHH:mm:ss')
                .parse(json['created_at'] as String, true)
                .toLocal();

  Map<String, dynamic> toJson() => {
        '_id': id,
        'product_id': productId,
        'product': product == null ? null : product!.toJson(),
        'user_id': userId,
        'fridge_id': fridgeId,
        'initial_amount': initialAmount == null ? null : initialAmount!.toJson(),
        'amount': amount == null ? null : amount!.toJson(),
        'created_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt.toUtc()),
      };
}
