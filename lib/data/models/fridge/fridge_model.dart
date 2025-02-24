import '../../../domain/entities/fridge/fridge.dart';

class FridgeModel {
  final String id;

  FridgeModel({required this.id});

  @override
  String toString() => this.toJson().toString();

  factory FridgeModel.fromJson(Map<String, dynamic> json) {
    return FridgeModel(
        id: json['_id']
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
  };

  static FridgeModel fromDomain(Fridge fridge) {
    return FridgeModel(
      id: fridge.id,
    );
  }

  Fridge toDomain() {
    return Fridge(
      id: id,
    );
  }
}