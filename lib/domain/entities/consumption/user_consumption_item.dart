import '../product/product.dart';
import '/domain/entities/product/fridge_item.dart';
import 'consumed_amount.dart';

class UserConsumptionItem {
  final String? id;
  final String? productId;
  final Product? product;
  final String? fridgeItemId;
  final FridgeItem? fridgeItem;
  final ConsumedAmount? consumedAmount;
  final String? type;
  final DateTime createdAt;
  final DateTime consumedAt;

  UserConsumptionItem({
    this.id,
    this.productId,
    this.product,
    this.fridgeItemId,
    this.fridgeItem,
    this.consumedAmount,
    this.type,
    DateTime? createdAt,
    required this.consumedAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}
