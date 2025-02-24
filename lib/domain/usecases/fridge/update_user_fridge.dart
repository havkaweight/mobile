import 'package:havka/domain/repositories/fridge/fridge_repository.dart';

import '../../entities/fridge/user_fridge.dart';

class UpdateUserFridge {
  final FridgeRepository repository;

  UpdateUserFridge(this.repository);

  Future<void> execute(UserFridge userFridge) async {
    if (userFridge.id != "") {
      throw Exception("Fridge name cannot be empty");
    }
    await repository.updateUserFridge(userFridge);
  }
}