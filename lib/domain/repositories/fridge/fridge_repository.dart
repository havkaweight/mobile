import '../../entities/fridge/fridge.dart';
import '../../entities/fridge/user_fridge.dart';
import '../../entities/product/fridge_item.dart';

abstract class FridgeRepository {
  Future<List<Fridge>> getAllFridges();
  Future<List<UserFridge>> getAllUserFridges();
  Future<Fridge> getFridgeById(String id);

  Future<Fridge> createNewFridge();
  Future<void> deleteFridge(String id);

  Future<UserFridge> createUserFridge(String name, String? fridgeId);
  Future<UserFridge> updateUserFridge(UserFridge userFridge);
  Future<void> deleteUserFridge(UserFridge userFridge);

  Future<List<FridgeItem>> getAllFridgeItems(String fridgeId);
  Future<FridgeItem> getFridgeItemById(String id);

  Future<FridgeItem> createFridgeItem(String fridgeId, String productId);
  Future<FridgeItem> updateFridgeItem(FridgeItem fridgeItem);
  Future<void> deleteFridgeItem(String id);
}