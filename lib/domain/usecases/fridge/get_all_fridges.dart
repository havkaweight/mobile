import 'package:havka/domain/entities/fridge/fridge.dart';
import 'package:havka/domain/repositories/fridge/fridge_repository.dart';

class GetAllFridges {
  final FridgeRepository repository;

  GetAllFridges(this.repository);

  Future<List<Fridge>> execute() async {
    final fridges = await repository.getAllFridges();
    return fridges.toList();
  }
}