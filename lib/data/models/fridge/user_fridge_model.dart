import '../../../domain/entities/fridge/user_fridge.dart';

class UserFridgeModel {
  final String? id;
  final String name;
  final String fridgeId;

  UserFridgeModel({
    this.id,
    required this.name,
    required this.fridgeId,
  });

  factory UserFridgeModel.fromJson(Map<String, dynamic> json) {
    return UserFridgeModel(
      id: json['_id'],
      name: json['fridge_name'],
      fridgeId: json['fridge_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'fridge_name': name,
    'fridge_id': fridgeId,
  };

  @override
  String toString() => this.toJson().toString();

  UserFridge toDomain() {
    return UserFridge(
      id: id,
      name: name,
      fridgeId: fridgeId,
    );
  }

  static UserFridgeModel fromDomain(UserFridge userFridge) {
    return UserFridgeModel(
      id: userFridge.id,
      name: userFridge.name,
      fridgeId: userFridge.fridgeId,
    );
  }
}