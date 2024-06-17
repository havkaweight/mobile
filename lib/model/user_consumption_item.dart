import 'package:havka/model/product.dart';
import 'package:havka/model/user_fridge_item.dart';
import 'package:intl/intl.dart';

class ConsumedAmount {
  final Serving serving;
  final double value;

  const ConsumedAmount({
    required this.serving,
    required this.value,
  });

  ConsumedAmount.fromJson(Map<String, dynamic> json)
      : serving = Serving.fromJson(json["serving"]),
        value = json["value"];

  Map<String, dynamic> toJson() => {
    "serving": serving.toJson(),
    "value": value,
  };
}

class UserConsumptionItem {
  final String? id;
  final String? productId;
  final Product? product;
  final String? fridgeItemId;
  final UserFridgeItem? userFridgeItem;
  final ConsumedAmount? consumedAmount;
  final String? type;
  final DateTime createdAt;
  final DateTime consumedAt;

  UserConsumptionItem({
    this.id,
    this.productId,
    this.product,
    this.fridgeItemId,
    this.userFridgeItem,
    this.consumedAmount,
    this.type,
    DateTime? createdAt,
    required this.consumedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  @override
  toString() {
    return toJson().toString();
  }

  UserConsumptionItem.fromJson(Map<String, dynamic> json)
      : id = json["_id"] as String?,
        productId = json["product_id"],
        product = json["product"] == null
        ? null
        : Product.fromJson(json["product"]),
        fridgeItemId = json["fridge_item_id"],
        userFridgeItem = json["fridge_item"] == null
        ? null
        : UserFridgeItem.fromJson(json["fridge_item"]),
        consumedAmount = json["consumed_amount"] == null
            ? null
            : ConsumedAmount.fromJson(json["consumed_amount"]),
        type = json["type"],
        createdAt = DateFormat("yyyy-MM-ddTHH:mm:ss")
                .parse(
                  json["created_at"] as String,
                  true,
                )
                .toLocal(),
        consumedAt = DateFormat("yyyy-MM-ddTHH:mm:ss")
                .parse(
                  json["consumed_at"] as String,
                  true,
                )
                .toLocal();

  Map<String, dynamic> toJson() => {
        "_id": id,
        "product_id": productId,
        "product": product == null ? null : product!.toJson(),
        "fridge_item_id": fridgeItemId,
        "fridge_item": userFridgeItem == null ? null : userFridgeItem!.toJson(),
        "consumed_amount": consumedAmount == null ? null : consumedAmount!.toJson(),
        "type": type,
        "created_at": DateFormat("yyyy-MM-ddTHH:mm:ss").format(createdAt.toUtc()),
        "consumed_at": DateFormat("yyyy-MM-ddTHH:mm:ss").format(consumedAt.toUtc()),
      };
}
