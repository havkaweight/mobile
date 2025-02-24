import 'package:havka/domain/repositories/fridge/fridge_repository.dart';

class DeleteFridge {
  final FridgeRepository repository;

  DeleteFridge(this.repository);

  Future<void> execute(String fridgeId) async {
    await repository.deleteFridge(fridgeId);
  }
}