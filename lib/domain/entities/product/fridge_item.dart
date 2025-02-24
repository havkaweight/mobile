import 'package:havka/domain/entities/product/product.dart';
import 'package:havka/domain/entities/product/product_amount.dart';

class FridgeItem {
  final String? id;
  final Product product;
  final ProductAmount initialAmount;
  final ProductAmount amount;
  final DateTime createdAt;

  FridgeItem({
    this.id,
    required this.product,
    required this.initialAmount,
    required this.amount,
    required this.createdAt,
  });

  @override
  toString() => 'FridgeItem(id: $id, product: $product, initialAmount: $initialAmount, amount: $amount, createdAt: $createdAt)';
}