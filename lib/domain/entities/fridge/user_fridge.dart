import 'fridge.dart';

class UserFridge {
  final String? id;
  final String name;
  final Fridge? fridge;
  final String fridgeId;

  UserFridge({
    this.id,
    required this.name,
    this.fridge,
    required this.fridgeId,
  });
}