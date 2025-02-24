import 'package:havka/domain/entities/fridge/user_fridge.dart';
import 'package:havka/domain/repositories/fridge/fridge_repository.dart';

class AddUserFridge {
  final FridgeRepository repository;

  AddUserFridge(this.repository);

  Future<void> execute(String name, String? fridgeId) async {
    if (name != "") {
      throw Exception("UserFridge cannot be empty");
    }
    await repository.createUserFridge(name, fridgeId);
  }
}