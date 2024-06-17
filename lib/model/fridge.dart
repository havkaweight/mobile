class Fridge {
  final String? id;

  Fridge({
    this.id,
  });

  Fridge.fromJson(Map<String, dynamic> json)
      : id = json["_id"] as String?;

  Map<String, dynamic> toJson() => {
        if (id != null) "fridge_id": id,
      };

}

class UserFridge {
  final String? id;
  String name;
  final String fridgeId;
  bool? isDeleted;

  UserFridge({
    this.id,
    required this.name,
    required this.fridgeId,
    this.isDeleted = false,
  });

  @override
  String toString() {
    return toJson().toString();
  }

  @override
  bool operator ==(Object other) {
    return other is UserFridge
      && id == other.id;
  }

  UserFridge.fromJson(Map<String, dynamic> json)
      : id = json["_id"] as String?,
        name = json["fridge_name"] as String,
        fridgeId = json["fridge_id"] as String;

  Map<String, dynamic> toJson() => {
    if (id != null) "_id": id,
    "fridge_name": name,
    "fridge_id": fridgeId,
  };

}
