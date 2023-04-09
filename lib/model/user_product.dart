import 'package:health_tracker/model/product.dart';

class UserProduct {
  final String? id;
  final Product? product;
  final String? userId;
  final double? netWeightLeft;
  final String? unit;

  UserProduct({
    this.id,
    this.product,
    this.userId,
    this.netWeightLeft,
    this.unit,
  });

  UserProduct.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        product = json['product'] == null
            ? null
            : Product.fromJson(json['product'] as Map<String, dynamic>),
        userId = json['user_id'] as String?,
        netWeightLeft = json['net_weight_left'] as double?,
        unit = json['unit'] as String?;

  Map<String, dynamic> toJson() => {
        '_id': id,
        'product': product == null ? null : product!.toJson(),
        'user_id': userId,
        'net_weight_left': netWeightLeft,
        'unit': unit
      };

  Map<String, dynamic> idToJson() => {'id': id};
}
