import 'package:havka/data/models/consumption/consumed_amount_model.dart';
import 'package:havka/data/models/product/product_model.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/consumption/user_consumption_item.dart';
import '../product/fridge_item_model.dart';

class UserConsumptionItemModel {
  final String? id;
  final String? productId;
  final Map<String, dynamic>? product;
  final String? fridgeItemId;
  final Map<String, dynamic>? consumedAmount;
  final String? type;
  final DateTime createdAt;
  final DateTime consumedAt;

  UserConsumptionItemModel({
    this.id,
    this.productId,
    this.product,
    this.fridgeItemId,
    this.consumedAmount,
    this.type,
    DateTime? createdAt,
    required this.consumedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  @override
  toString() => this.toJson().toString();

  factory UserConsumptionItemModel.fromJson(Map<String, dynamic> json) {
    return UserConsumptionItemModel(
      id: json['_id'],
      productId: json['product_id'],
      product: json['product'],
      fridgeItemId: json['fridge_item_id'],
      consumedAmount: json['consumed_amount'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      consumedAt: DateTime.parse(json['consumed_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'product_id': productId,
      'product': product,
      'fridge_item_id': fridgeItemId,
      'consumed_amount': consumedAmount,
      'type': type,
      'created_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt.toUtc()),
      'consumed_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(consumedAt.toUtc()),
    };
  }

  UserConsumptionItem toDomain() {
    return UserConsumptionItem(
      id: id,
      productId: productId,
      product: product != null ? ProductModel.fromJson(product!).toDomain() : null,
      fridgeItemId: fridgeItemId,
      consumedAmount: consumedAmount != null ? ConsumedAmountModel.fromJson(consumedAmount!).toDomain() : null,
      type: type,
      createdAt: createdAt,
      consumedAt: consumedAt,
    );
  }

  static UserConsumptionItemModel fromDomain(UserConsumptionItem consumptionItem) {
    return UserConsumptionItemModel(
      id: consumptionItem.id,
      productId: consumptionItem.productId,
      product: consumptionItem.product != null ? ProductModel.fromDomain(consumptionItem.product!).toJson() : null,
      fridgeItemId: consumptionItem.fridgeItemId,
      consumedAmount: consumptionItem.consumedAmount != null ? ConsumedAmountModel.fromDomain(consumptionItem.consumedAmount!).toJson() : null,
      type: consumptionItem.type,
      createdAt: consumptionItem.createdAt,
      consumedAt: consumptionItem.consumedAt,
    );
  }
}
