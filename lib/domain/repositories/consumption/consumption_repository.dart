import 'package:havka/domain/entities/consumption/user_consumption_item.dart';
import '../../entities/consumption/consumed_amount.dart';
import '../../entities/product/product.dart';

abstract class ConsumptionRepository {
  Future<List<UserConsumptionItem>> getConsumptionItems();
  Future<UserConsumptionItem> getConsumptionItemById(String id);
  Future<List<UserConsumptionItem>> getConsumptionItemsByProduct(Product product);
  Future<UserConsumptionItem> addConsumptionItem(UserConsumptionItem userConsumptionItem);
  Future<UserConsumptionItem> updateConsumptionItem(UserConsumptionItem userConsumptionItem);
  Future<void> deleteConsumptionItem(String id);
}