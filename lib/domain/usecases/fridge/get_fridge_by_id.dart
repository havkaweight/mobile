import 'package:havka/domain/entities/fridge/fridge.dart';
import 'package:havka/domain/repositories/fridge/fridge_repository.dart';

class GetFridgeById {
  final FridgeRepository repository;

  GetFridgeById(this.repository);

  Future<Fridge?> execute(String fridgeId) async {
    return await repository.getFridgeById(fridgeId);
  }
}