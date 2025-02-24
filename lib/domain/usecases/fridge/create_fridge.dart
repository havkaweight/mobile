import 'package:havka/domain/entities/fridge/fridge.dart';
import 'package:havka/domain/repositories/fridge/fridge_repository.dart';

class CreateFridge {
  final FridgeRepository _repository;

  CreateFridge(this._repository);

  Future<Fridge> execute() async {
    return await _repository.createNewFridge();
  }
}